#!/bin/bash

set -e # Ensure the script exits on any command failure
set -x # Print each command before executing it for debugging

BASE_URL=https://release.memsql.com/production/debian/pool/
VERSIONS_FILE="versions.txt"
BUILT_MARKER=".built_versions"
DOCKER_IMAGE_NAME="nithinm/singlestore-studio"

echo "Checking for the existence of $BUILT_MARKER file..."
[ ! -f "$BUILT_MARKER" ] && touch "$BUILT_MARKER" && echo "$BUILT_MARKER file created."

build_and_push() {
  local version=$1
  local build_only=$2

  # Extract the version number for tagging
  local tag=$(echo "$version" | sed -E 's/singlestoredb-studio_([^-]+).*/\1/')
  echo "Version to process: $version with tag: $tag"

  echo "Building Docker image for version: $tag"
  docker build --build-arg VERSION="$version" --build-arg BASE_URL="$BASE_URL" -t "$DOCKER_IMAGE_NAME:$tag" .
  echo "Docker image $DOCKER_IMAGE_NAME:$tag built successfully."

  if [[ "$build_only" != "true" ]]; then
    echo "Pushing Docker image for version: $tag"
    docker push "$DOCKER_IMAGE_NAME:$tag"
    echo "Docker image $DOCKER_IMAGE_NAME:$tag pushed successfully."

    # Mark this version as built
    echo "Marking $version as built."
    echo "$version" >> "$BUILT_MARKER"

    # Tag and push the latest version
    docker tag "$DOCKER_IMAGE_NAME:$tag" "$DOCKER_IMAGE_NAME:latest"
    docker push "$DOCKER_IMAGE_NAME:latest"
    echo "$DOCKER_IMAGE_NAME:$tag tagged as latest and pushed."
  else
    echo "Build-only mode, skipping push."
  fi
}

echo "Starting script execution with option: $1"
case "$1" in
  --build-only)
    echo "Executing in build-only mode."
    version=$(tail -n 1 "$VERSIONS_FILE")
    build_and_push "$version" true
    ;;

  --build-push-mark)
    echo "Executing in build-push-mark mode."
    echo "Contents of $VERSIONS_FILE:"
    cat "$VERSIONS_FILE"
    echo "End of $VERSIONS_FILE content."
    while IFS='' read -r version || [[ -n "$version" ]]; do
      echo "Processing version: $version"
      if grep -q "^$version$" "$BUILT_MARKER"; then
        echo "$version already built, skipping..."
      else
        build_and_push "$version" false
      fi
    done < "$VERSIONS_FILE"
    ;;

  *)
    echo "Invalid option: $1. Use --build-only for PR builds or --build-push-mark for post-approval builds."
    exit 1
    ;;
esac

echo "Script execution completed."
