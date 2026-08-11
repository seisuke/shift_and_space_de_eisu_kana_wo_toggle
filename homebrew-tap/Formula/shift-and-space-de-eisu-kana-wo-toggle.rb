class ShiftAndSpaceDeEisuKanaWoToggle < Formula
  desc "Toggle macOS Eisu/Kana input with Shift+Space"
  homepage "https://github.com/seisuke/shift_and_space_de_eisu_kana_wo_toggle"
  head "https://github.com/seisuke/shift_and_space_de_eisu_kana_wo_toggle.git", branch: "main"

  depends_on xcode: ["26.0", :build]
  depends_on macos: :tahoe

  def install
    system "make", "app"
    prefix.install ".build/app/shift_and_space_de_eisu_kana_wo_toggle.app"
  end

  def caveats
    <<~EOS
      Start the app with:
        open #{opt_prefix}/shift_and_space_de_eisu_kana_wo_toggle.app

      Then allow it in System Settings > Privacy & Security > Accessibility.
    EOS
  end

  test do
    app = prefix/"shift_and_space_de_eisu_kana_wo_toggle.app"
    executable = app/"Contents/MacOS/shift_and_space_de_eisu_kana_wo_toggle"
    assert_predicate executable, :executable?
  end
end
