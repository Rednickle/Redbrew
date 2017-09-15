class Hexedit < Formula
  desc "View and edit files in hexadecimal or ASCII"
  homepage "http://rigaux.org/hexedit.html"
  url "https://github.com/pixel/hexedit/archive/1.4.2.tar.gz"
  sha256 "c81ffb36af9243aefc0887e33dd8e41c4b22d091f1f27d413cbda443b0440d66"
  head "https://github.com/pixel/hexedit.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "fbdf1a49a8ab54301abb8ac9df6a5ff10190bae5f2d6c976cc61ea86e0fa411a" => :x86_64_linux
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    shell_output("#{bin}/hexedit -h 2>&1", 1)
  end
end
