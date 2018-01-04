class Fonttools < Formula
  include Language::Python::Virtualenv

  desc "Library for manipulating fonts"
  homepage "https://github.com/fonttools/fonttools"
  url "https://github.com/fonttools/fonttools/releases/download/3.21.1/fonttools-3.21.1.zip"
  sha256 "abcf4e749e89b612fb6a1a0814d939bab604c5d783147768ba9d8cba86aa0af2"
  head "https://github.com/fonttools/fonttools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "76bc5b800161c11f68770101a85df5539008aed5b5d7ff4cf3815f9d13e49f87" => :high_sierra
    sha256 "2d0570cf3496c8850be8092f08615c61faa5b0e5e34dd393b96d991f52c1d790" => :sierra
    sha256 "30eba417de8d2c647f8f904540da19f9a25c96a4925c2283076a0b32a30a227c" => :el_capitan
    sha256 "3a92202e09ea54932888d5e4ea79bc1d5b8d179735a49845aae90d2b0669ac2a" => :x86_64_linux
  end

  option "with-pygtk", "Build with pygtk support for pyftinspect"

  depends_on "python" if MacOS.version <= :snow_leopard
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
