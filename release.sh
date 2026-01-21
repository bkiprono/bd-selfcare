#!/bin/bash
set -e

# ====== CONFIG ======
PUBSPEC="pubspec.yaml"
APP_BUILD_GRADLE="android/app/build.gradle.kts"

# ====== FUNCTIONS ======
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

current_version=$(get_current_version)
echo "Current version: $current_version"

new_version=$(bump_version "$current_version" "$BUMP_TYPE")
echo "New version: $new_version"

update_pubspec "$new_version"

echo "Building release AppBundle..."
flutter clean
flutter pub get
flutter build appbundle --release

echo "Tagging release..."
git add $PUBSPEC
git commit -m "chore(release): bump version to $new_version"
git tag "v$new_version"
git push && git push --tags

echo "Release complete! 🎉"