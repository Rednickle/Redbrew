class Fonttools < Formula
  include Language::Python::Virtualenv

  desc "Library for manipulating fonts"
  homepage "https://github.com/fonttools/fonttools"
  url "https://github.com/fonttools/fonttools/releases/download/3.25.0/fonttools-3.25.0.zip"
  sha256 "c1b7eb0469d4e684bb8995906c327109beac870a33900090d64f85d79d646360"
  head "https://github.com/fonttools/fonttools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d2ca7d400c54fdc2baa74f0a435a15ada507efdd283e17fe43f0f6b6f92d685b" => :high_sierra
    sha256 "bde49befe8e90387711ad55b85f30babb50620ce61892b7c13ecedc7d1226eaf" => :sierra
    sha256 "918f37a73c638999e4655ed0eb51f71ffc4711f9570380098dd310b027fc7aa3" => :el_capitan
    sha256 "b2b7775585fb9d5380334d0a07e35e8edda4e33622dfe9e4bee4f66fed5dafef" => :x86_64_linux
  end

  option "with-pygtk", "Build with pygtk support for pyftinspect"

  depends_on "python@2"
  depends_on "pygtk" => :optional

  def install
    virtualenv_install_with_resources
  end

  test do
    unless OS.mac?
      assert_match "usage", shell_output("#{bin}/ttx -h")
      return
    end
    cp "/Library/Fonts/Arial.ttf", testpath
    system bin/"ttx", "Arial.ttf"
  end
end
