#!/bin/zsh
set -euo pipefail

root_dir=${0:A:h:h}
app_name=shift_and_space_de_eisu_kana_wo_toggle
version=${VERSION:?VERSION is required}
app_dir="$root_dir/.build/app/$app_name.app"
release_dir="$root_dir/.build/release"
submission_zip="$release_dir/$app_name-$version-notarization.zip"
release_zip="$release_dir/$app_name-$version.zip"

if [[ ! -d "$app_dir" ]]; then
    print -u2 "App bundle not found: $app_dir"
    exit 1
fi

rm -rf "$release_dir"
mkdir -p "$release_dir"

codesign --verify --strict --verbose=2 "$app_dir"
ditto -c -k --keepParent "$app_dir" "$submission_zip"

if [[ -n "${APP_STORE_CONNECT_KEY_PATH:-}" ]]; then
    : "${APP_STORE_CONNECT_KEY_ID:?APP_STORE_CONNECT_KEY_ID is required}"
    : "${APP_STORE_CONNECT_ISSUER_ID:?APP_STORE_CONNECT_ISSUER_ID is required}"
    xcrun notarytool submit "$submission_zip" \
        --key "$APP_STORE_CONNECT_KEY_PATH" \
        --key-id "$APP_STORE_CONNECT_KEY_ID" \
        --issuer "$APP_STORE_CONNECT_ISSUER_ID" \
        --wait
else
    : "${APPLE_ID:?APPLE_ID is required}"
    : "${APPLE_APP_SPECIFIC_PASSWORD:?APPLE_APP_SPECIFIC_PASSWORD is required}"
    : "${APPLE_TEAM_ID:?APPLE_TEAM_ID is required}"
    xcrun notarytool submit "$submission_zip" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_APP_SPECIFIC_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --wait
fi

xcrun stapler staple "$app_dir"
xcrun stapler validate "$app_dir"
codesign --verify --strict --verbose=2 "$app_dir"
spctl --assess --type execute --verbose=4 "$app_dir"

ditto -c -k --keepParent "$app_dir" "$release_zip"
rm -f "$submission_zip"

echo "$release_zip"
