#!/bin/bash

VERSIONS_FILE="versions.txt"
BUILT_MARKER=".built_versions"
DOCKER_IMAGE_NAME="nithinm/singlestore-studio"

# Ensure the marker file exists
touch "$BUILT_MARKER"

# Function to build and optionally push Docker images
build_and_push() {
  local version=$1
  local build_only=$2

  # Extract just the version number for tagging
  local tag=$(echo "$version" | sed -E 's/singlestoredb-studio_([^-]+).*/\1/')

  echo "Building Docker image for version: $tag"

  # Build the Docker image, passing the VERSION as a build argument
  docker build --build-arg VERSION="$version" -t "$DOCKER_IMAGE_NAME:$tag" .

  if [[ "$build_only" != "true" ]]; then
    echo "Pushing Docker image for version: $tag"
    docker push "$DOCKER_IMAGE_NAME:$tag"

    # Mark this version as built
    echo "$version" >> "$BUILT_MARKER"

    # Tag the latest version
    docker tag "$DOCKER_IMAGE_NAME:$tag" "$DOCKER_IMAGE_NAME:latest"
    docker push "$DOCKER_IMAGE_NAME:latest"
  fi
}

# Main logic based on the script arguments
case "$1" in
  --build-only)
    # Read the last version from the versions file for a PR build
    version=$(tail -n 1 "$VERSIONS_FILE")
    build_and_push "$version" true
    ;;

  --build-push-mark)
    # Iterate through each version in the versions file for an approval build
    while IFS= read -r version; do
      if grep -q "$version" "$BUILT_MARKER"; then
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
