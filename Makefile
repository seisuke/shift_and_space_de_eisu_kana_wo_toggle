.PHONY: app build test clean install release

build:
	CLANG_MODULE_CACHE_PATH="$(CURDIR)/.build/clang-module-cache" SWIFTPM_MODULECACHE_OVERRIDE="$(CURDIR)/.build/swift-module-cache" swift build --disable-sandbox -c release

test:
	CLANG_MODULE_CACHE_PATH="$(CURDIR)/.build/clang-module-cache" SWIFTPM_MODULECACHE_OVERRIDE="$(CURDIR)/.build/swift-module-cache" swift test --disable-sandbox

app:
	./scripts/build-app.sh

release:
	@test -n "$(VERSION)" || (echo "VERSION is required" >&2; exit 1)
	@test -n "$(CODE_SIGN_IDENTITY)" || (echo "CODE_SIGN_IDENTITY is required" >&2; exit 1)
	VERSION="$(VERSION)" BUILD_NUMBER="$${BUILD_NUMBER:-1}" CODE_SIGN_IDENTITY="$(CODE_SIGN_IDENTITY)" ./scripts/build-app.sh
	VERSION="$(VERSION)" ./scripts/notarize-release.sh

install: app
	mkdir -p "$(HOME)/Applications"
	ditto .build/app/shift_and_space_de_eisu_kana_wo_toggle.app "$(HOME)/Applications/shift_and_space_de_eisu_kana_wo_toggle.app"

clean:
	swift package clean
	rm -rf .build/app
