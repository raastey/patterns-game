#!/usr/bin/env bash
# Archive, export App Store IPA, upload to App Store Connect / TestFlight.
set -euo pipefail

XCODE_SCHEME="PatternPath"
ARCHIVE_BASENAME="PatternPath"
IPA_BASENAME="PatternPath.ipa"
BUNDLE_ID="fun.raastey.patternpath"
TEAM_ID="${DEVELOPMENT_TEAM:-P3UCBA6NAQ}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -f "$ROOT/asc.env" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    export "$line"
  done < "$ROOT/asc.env"
elif [[ -f "$ROOT/../half-app/asc.env" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    export "$line"
  done < "$ROOT/../half-app/asc.env"
fi
cd "$ROOT"

if [[ -z "${ASC_KEY_ID:-}" ]]; then
  ASC_KEY_ID="LVXMBUT28V"
fi
if [[ -z "${ASC_KEY_PATH:-}" ]]; then
  if [[ -f "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8" ]]; then
    ASC_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
  elif [[ -f "$ROOT/../medium-format/AuthKey_${ASC_KEY_ID}.p8" ]]; then
    ASC_KEY_PATH="$ROOT/../medium-format/AuthKey_${ASC_KEY_ID}.p8"
  fi
fi

ARCHIVE_PATH="build/${ARCHIVE_BASENAME}.xcarchive"
EXPORT_PATH="build/export"
IPA_PATH="$EXPORT_PATH/${IPA_BASENAME}"
UPLOAD_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --upload-only) UPLOAD_ONLY=true ;;
  esac
done

if [[ "$UPLOAD_ONLY" == false ]]; then
  export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
  echo "==> xcodegen"
  xcodegen generate

  echo "==> archive (Release, team $TEAM_ID)"
  rm -rf "$ARCHIVE_PATH" .derivedData
  xcodebuild -scheme "$XCODE_SCHEME" \
    -derivedDataPath .derivedData \
    -destination 'generic/platform=iOS' \
    -configuration Release \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Automatic \
    -allowProvisioningUpdates \
    archive \
    -archivePath "$ARCHIVE_PATH"

  echo "==> export IPA"
  rm -rf "$EXPORT_PATH"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist ExportOptions.plist \
    -allowProvisioningUpdates \
    -authenticationKeyPath "$ASC_KEY_PATH" \
    -authenticationKeyID "$ASC_KEY_ID" \
    -authenticationKeyIssuerID "$ASC_ISSUER_ID"
fi

if [[ ! -d "$ARCHIVE_PATH" && "$UPLOAD_ONLY" == false ]]; then
  echo "ERROR: Archive not found at $ARCHIVE_PATH"
  exit 1
fi

# IPA name can vary; pick first .ipa
if [[ ! -f "$IPA_PATH" ]]; then
  IPA_PATH="$(find "$EXPORT_PATH" -maxdepth 1 -name '*.ipa' | head -1 || true)"
fi
if [[ -z "${IPA_PATH:-}" || ! -f "$IPA_PATH" ]]; then
  echo "ERROR: Export failed — no IPA in $EXPORT_PATH"
  exit 1
fi

echo "==> IPA ready: $IPA_PATH ($(du -h "$IPA_PATH" | awk '{print $1}'))"
codesign -d --verbose=2 "$IPA_PATH" 2>&1 | head -5 || true

if [[ -z "${ASC_ISSUER_ID:-}" || -z "${ASC_KEY_PATH:-}" ]]; then
  echo "ERROR: ASC credentials missing (ASC_ISSUER_ID / ASC_KEY_PATH)"
  exit 1
fi

echo "==> upload to App Store Connect"
mkdir -p "${HOME}/.appstoreconnect/private_keys"
if [[ -f "$ASC_KEY_PATH" && ! -f "${HOME}/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8" ]]; then
  cp "$ASC_KEY_PATH" "${HOME}/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
  chmod 600 "${HOME}/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
fi

xcrun altool --upload-app \
  --type ios \
  --file "$IPA_PATH" \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"

echo "==> done. Bundle ID: $BUNDLE_ID"
echo "    After processing, the build appears under the Pattern Path app in Connect."
