#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

echo "==> xcodegen"
xcodegen generate

DEST='platform=iOS Simulator,name=iPad (A16)'

echo "==> Debug build"
xcodebuild \
  -scheme PatternPath \
  -destination "$DEST" \
  -configuration Debug \
  -quiet \
  build

echo "==> Release build (simulator, no sign)"
xcodebuild \
  -scheme PatternPath \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Release \
  -quiet \
  CODE_SIGNING_ALLOWED=NO \
  build

echo "==> verify ok"
