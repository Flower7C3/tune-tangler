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
CURRENT_SEMANTIC_VERSION=$(echo "$CURRENT_VERSION" | sed 's/+.*//')
CURRENT_BUILD=$(echo "$CURRENT_VERSION" | sed 's/.*+//')

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION="$CURRENT_SEMANTIC_VERSION+$NEW_BUILD"

echo "Version updated to: $NEW_VERSION (build: $CURRENT_BUILD->$NEW_BUILD)"

# Update pubspec.yaml
sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC_PATH"
