.PHONY: app build test clean install

build:
	CLANG_MODULE_CACHE_PATH="$(CURDIR)/.build/clang-module-cache" SWIFTPM_MODULECACHE_OVERRIDE="$(CURDIR)/.build/swift-module-cache" swift build --disable-sandbox -c release

test:
	CLANG_MODULE_CACHE_PATH="$(CURDIR)/.build/clang-module-cache" SWIFTPM_MODULECACHE_OVERRIDE="$(CURDIR)/.build/swift-module-cache" swift test --disable-sandbox

app:
	./scripts/build-app.sh

install: app
	mkdir -p "$(HOME)/Applications"
	ditto .build/app/shift_and_space_de_eisu_kana_wo_toggle.app "$(HOME)/Applications/shift_and_space_de_eisu_kana_wo_toggle.app"

clean:
	swift package clean
	rm -rf .build/app
