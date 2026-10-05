#!/usr/bin/env bash
#
# Increments the app version in pubspec.yaml before a release build.
#
# Play Console refuses an upload whose versionCode it has already seen, so the
# code has to move every time a bundle is produced. The patch part of the
# versionName moves with it, which keeps the number a user reads in the store
# in step with the number Play tracks.
#
# Usage:
#   tool/bump_version.sh            # 1.0.1+2 -> 1.0.2+3
#   tool/bump_version.sh 2.0.0      # force a versionName, still bumps the code
#   tool/bump_version.sh --dry-run  # print the result, write nothing

set -euo pipefail

cd "$(dirname "$0")/.."
PUBSPEC="pubspec.yaml"

dry_run=0
forced=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    -*) echo "unknown option: $arg" >&2; exit 1 ;;
    *) forced="$arg" ;;
  esac
done

current="$(grep -E '^version:[[:space:]]' "$PUBSPEC" | head -1 | sed -E 's/^version:[[:space:]]*//')"

if [[ ! "$current" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  echo "cannot read a name+code version from '$current'" >&2
  echo "expected MAJOR.MINOR.PATCH+CODE" >&2
  exit 1
fi

name="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
code="${BASH_REMATCH[4]}"

if [[ -n "$forced" ]]; then
  if [[ ! "$forced" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "forced version must look like 2.0.0" >&2
    exit 1
  fi
  name="$forced"
else
  IFS=. read -r major minor patch <<< "$name"
  name="${major}.${minor}.$((patch + 1))"
fi

code=$((code + 1))
next="${name}+${code}"

echo "  $current  ->  $next"

if [[ "$dry_run" -eq 1 ]]; then
  echo "(dry run, $PUBSPEC untouched)"
  exit 0
fi

sed -i -E "s/^version:[[:space:]].*/version: ${next}/" "$PUBSPEC"

echo "updated $PUBSPEC"
