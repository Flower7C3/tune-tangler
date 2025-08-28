#!/bin/bash

# Script to install pre-commit hook for automatic version incrementing

set -e

echo "🔧 Installing pre-commit hook..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "   Please run this script from the root of your git repository"
    exit 1
fi

# Check if hooks directory exists
if [ ! -d ".git/hooks" ]; then
    echo "❌ Error: .git/hooks directory not found"
    exit 1
fi

# Copy pre-commit hook
if [ -f ".git/hooks/pre-commit" ]; then
    echo "📝 Pre-commit hook already exists, backing up..."
    cp .git/hooks/pre-commit .git/hooks/pre-commit.backup
fi

# Copy the hook from scripts directory
if [ -f "scripts/pre-commit" ]; then
    cp scripts/pre-commit .git/hooks/pre-commit
    echo "✅ Pre-commit hook copied from scripts/"
elif [ -f ".git/hooks/pre-commit" ]; then
    echo "✅ Pre-commit hook already in place"
else
    echo "❌ Error: Pre-commit hook not found in scripts/"
    exit 1
fi

# Make it executable
chmod +x .git/hooks/pre-commit

# Verify installation
if [ -x ".git/hooks/pre-commit" ]; then
    echo "✅ Pre-commit hook installed successfully!"
    echo "📋 Hook will now automatically increment minor version before each commit"
    echo ""
    echo "💡 To test:"
    echo "   1. Make some changes to your code"
    echo "   2. git add ."
    echo "   3. git commit -m 'test commit'"
    echo "   4. Check pubspec.yaml for version increment"
    echo ""
    echo "🔧 To disable temporarily: git commit --no-verify"
    echo "🗑️  To remove permanently: rm .git/hooks/pre-commit"
else
    echo "❌ Error: Failed to make pre-commit hook executable"
    exit 1
fi
