#!/bin/bash

# Increment build version in pubspec.yaml
# Usage: ./scripts/increment_build.sh

set -e

PUBSPEC_PATH="pubspec.yaml"

if [ ! -f "$PUBSPEC_PATH" ]; then
    echo "Error: $PUBSPEC_PATH not found!"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep '^version:' "$PUBSPEC_PATH" | sed 's/.*version: //')
echo "Current version: $CURRENT_VERSION"

# Split version into parts
VERSION_ONLY=$(echo "$CURRENT_VERSION" | sed 's/+.*//')
BUILD_NUM=$(echo "$CURRENT_VERSION" | sed 's/.*+//')

# Increment build number
NEW_BUILD_NUM=$((BUILD_NUM + 1))
NEW_VERSION="$VERSION_ONLY+$NEW_BUILD_NUM"

echo "Version updated to: $NEW_VERSION (build: $BUILD_NUM->$NEW_BUILD_NUM)"

# Update pubspec.yaml
sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC_PATH"
