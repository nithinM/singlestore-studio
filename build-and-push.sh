#!/bin/bash

set -e # Ensure the script exits on any command failure
BASE_URL=https://release.memsql.com/production/debian/pool/
VERSIONS_FILE="versions.txt"
BUILT_MARKER=".built_versions"
DOCKER_IMAGE_NAME="nithinm/singlestore-studio"

# Check and touch the marker file to ensure it exists
[ ! -f "$BUILT_MARKER" ] && touch "$BUILT_MARKER"

build_and_push() {
  local version=$1
  local build_only=$2

  # Extract the version number for tagging
  local tag=$(echo "$version" | sed -E 's/singlestoredb-studio_([^-]+).*/\1/')

  echo "Building Docker image for version: $tag"
  docker build --build-arg VERSION="$version" --build-arg BASE_URL="$BASE_URL" -t "$DOCKER_IMAGE_NAME:$tag" .

  if [[ "$build_only" != "true" ]]; then
    echo "Pushing Docker image for version: $tag"
    docker push "$DOCKER_IMAGE_NAME:$tag"

    # Mark this version as built
    echo "$version" >> "$BUILT_MARKER"

    # Tag and push the latest version
    docker tag "$DOCKER_IMAGE_NAME:$tag" "$DOCKER_IMAGE_NAME:latest"
    docker push "$DOCKER_IMAGE_NAME:latest"
  fi
}

case "$1" in
  --build-only)
    version=$(tail -n 1 "$VERSIONS_FILE") # Removed 'local' keyword
    build_and_push "$version" true
    ;;

  --build-push-mark)
    while IFS= read -r version; do
      if grep -q "^$version$" "$BUILT_MARKER"; then # More precise matching
        echo "$version already built, skipping..."
        continue
      fi
      build_and_push "$version" false
    done < "$VERSIONS_FILE"
    ;;

  *)
    echo "Invalid option. Use --build-only for PR builds or --build-push-mark for post-approval builds."
    exit 1
    ;;
esac
