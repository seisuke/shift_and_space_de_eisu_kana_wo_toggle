#!/bin/zsh
set -euo pipefail

root_dir=${0:A:h:h}
configuration=${CONFIGURATION:-release}
version=${VERSION:-0.1.0}
build_number=${BUILD_NUMBER:-1}
code_sign_identity=${CODE_SIGN_IDENTITY:--}
app_name=shift_and_space_de_eisu_kana_wo_toggle
bundle_identifier=com.seisuke.shift-and-space-de-eisu-kana-wo-toggle
build_dir="$root_dir/.build/app"
app_dir="$build_dir/$app_name.app"
contents_dir="$app_dir/Contents"
iconset_dir="$build_dir/AppIcon.iconset"

cd "$root_dir"
export CLANG_MODULE_CACHE_PATH="$root_dir/.build/clang-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$root_dir/.build/swift-module-cache"
swift build --disable-sandbox -c "$configuration"
binary_path=$(swift build --disable-sandbox -c "$configuration" --show-bin-path)/$app_name

rm -rf "$app_dir" "$iconset_dir"
mkdir -p "$contents_dir/MacOS" "$contents_dir/Resources" "$iconset_dir"
cp "$binary_path" "$contents_dir/MacOS/$app_name"
cp Resources/Info.plist "$contents_dir/Info.plist"
cp Resources/StatusKana.png Resources/StatusEisu.png "$contents_dir/Resources/"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" \
    "$contents_dir/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" \
    "$contents_dir/Info.plist"

swift scripts/generate_icon.swift "$build_dir/AppIcon-1024.png"
for spec in '16 icon_16x16.png' '32 icon_16x16@2x.png' \
            '32 icon_32x32.png' '64 icon_32x32@2x.png' \
            '128 icon_128x128.png' '256 icon_128x128@2x.png' \
            '256 icon_256x256.png' '512 icon_256x256@2x.png' \
            '512 icon_512x512.png' '1024 icon_512x512@2x.png'; do
    pixels=${spec%% *}
    filename=${spec#* }
    sips -z "$pixels" "$pixels" "$build_dir/AppIcon-1024.png" \
        --out "$iconset_dir/$filename" >/dev/null
done
iconutil -c icns "$iconset_dir" -o "$contents_dir/Resources/AppIcon.icns"

if [[ "$code_sign_identity" == "-" ]]; then
    codesign --force --sign - \
        --identifier "$bundle_identifier" \
        --requirements "=designated => identifier \"$bundle_identifier\"" \
        "$app_dir"
else
    codesign --force \
        --options runtime \
        --timestamp \
        --sign "$code_sign_identity" \
        --identifier "$bundle_identifier" \
        "$app_dir"
fi
echo "$app_dir"
