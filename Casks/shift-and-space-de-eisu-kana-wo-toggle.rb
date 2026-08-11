cask "shift-and-space-de-eisu-kana-wo-toggle" do
  version "0.2.0"
  sha256 "d5b8bb1c63045add4136d47a826420b3cf248aa8f385f440c2aa91758bdb3168"

  url "https://github.com/seisuke/shift_and_space_de_eisu_kana_wo_toggle/releases/download/v#{version}/shift_and_space_de_eisu_kana_wo_toggle-#{version}.zip"
  name "shift_and_space_de_eisu_kana_wo_toggle"
  desc "Toggle Eisu/Kana input with Shift+Space"
  homepage "https://github.com/seisuke/shift_and_space_de_eisu_kana_wo_toggle"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "shift_and_space_de_eisu_kana_wo_toggle.app"

  zap trash: "~/Library/Preferences/com.seisuke.shift-and-space-de-eisu-kana-wo-toggle.plist"

  caveats <<~EOS
    Allow the app in System Settings > Privacy & Security > Accessibility.
  EOS
end
