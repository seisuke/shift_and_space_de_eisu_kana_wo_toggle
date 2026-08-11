cask "shift-and-space-de-eisu-kana-wo-toggle" do
  version "0.1.0"
  sha256 :no_check

  url "https://github.com/seisuke/shift_and_space_de_eisu_kana_wo_toggle/releases/download/v#{version}/shift_and_space_de_eisu_kana_wo_toggle-#{version}.zip"
  name "shift_and_space_de_eisu_kana_wo_toggle"
  desc "Toggle Eisu/Kana input with Shift+Space"
  homepage "https://github.com/seisuke/shift_and_space_de_eisu_kana_wo_toggle"

  depends_on macos: :tahoe

  app "shift_and_space_de_eisu_kana_wo_toggle.app"

  zap trash: "~/Library/Preferences/com.seisuke.shift-and-space-de-eisu-kana-wo-toggle.plist"

  caveats <<~EOS
    Allow the app in System Settings > Privacy & Security > Accessibility.
  EOS
end
