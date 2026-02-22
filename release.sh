#!/bin/bash
set -e

# ====== CONFIG ======
PUBSPEC="pubspec.yaml"
APP_BUILD_GRADLE="android/app/build.gradle.kts"

# ====== FUNCTIONS ======
function check_env() {
  echo "Checking environment..."
  
  # Ensure we are on main branch
  current_branch=$(git branch --show-current)
  if [ "$current_branch" != "main" ]; then
    echo "Error: Must be on 'main' branch to release (current: $current_branch)"
    exit 1
  fi

  # Ensure working tree is clean
  if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working tree is not clean. Please commit or stash changes."
    exit 1
  fi

  # Ensure GitHub CLI is installed and authenticated
  if ! command -v gh &> /dev/null; then
    echo "Error: gh (GitHub CLI) is not installed."
    exit 1
  fi
  
  if ! gh auth status &> /dev/null; then
    echo "Error: gh is not authenticated. Run 'gh auth login' first."
    exit 1
  fi
}

function get_current_version() {
  grep '^version:' $PUBSPEC | awk '{print $2}'
}

function bump_version() {
  local version=$1
  local part=$2

  IFS='+' read -r versionName versionCode <<< "$version"
  IFS='.' read -r major minor patch <<< "$versionName"

  case "$part" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
    *)
      echo "Invalid bump type: $part"
      exit 1
      ;;
  esac

  versionName="$major.$minor.$patch"
  versionCode=$((versionCode + 1))

  echo "$versionName+$versionCode"
}

function update_pubspec() {
  local new_version=$1
  sed -i.bak "s/^version: .*/version: $new_version/" $PUBSPEC
  rm -f "${PUBSPEC}.bak"
}

# ====== MAIN ======
BUMP_TYPE=${1:-patch}

# 0. Check Environment
check_env

current_version=$(get_current_version)
echo "Current version: $current_version"

new_version=$(bump_version "$current_version" "$BUMP_TYPE")
echo "New version: $new_version"

# 1. Update Version
update_pubspec "$new_version"

# 2. Build Artifacts
echo "Building release AppBundle..."
flutter clean
flutter pub get
flutter build appbundle --release

# 3. Git Operations
echo "Committing and Tagging release..."
git add $PUBSPEC
git commit -m "chore(release): bump version to $new_version"
git tag "v$new_version"
git push origin main
git push origin "v$new_version"

# 4. Create GitHub Release
echo "Creating GitHub release..."
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ -f "$AAB_PATH" ]; then
  gh release create "v$new_version" "$AAB_PATH" \
    --title "Release v$new_version" \
    --notes "Release for version $new_version" \
    --target main
else
  echo "Warning: Release artifact not found at $AAB_PATH. Skipping GitHub release creation."
fi

echo "Release v$new_version complete! 🎉"
