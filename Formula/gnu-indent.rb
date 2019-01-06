class GnuIndent < Formula
  desc "C code prettifier"
  homepage "https://www.gnu.org/software/indent/"
  url "https://ftp.gnu.org/gnu/indent/indent-2.2.12.tar.gz"
  mirror "https://ftpmirror.gnu.org/indent/indent-2.2.12.tar.gz"
  sha256 "e77d68c0211515459b8812118d606812e300097cfac0b4e9fb3472664263bb8b"

  bottle do
    rebuild 1
    sha256 "af195d9c6363843cee1a9ec8707cdcedb193fd74dbcd1abcb34781baac0231ed" => :mojave
    sha256 "7402c4707255b5d9d80208dcb922b37a8d0753c6143d291c53fc2774d6b23088" => :high_sierra
    sha256 "059d45ddc36600a53e52afd810123570e0bd277fc11f6c1b6b7c594919ab84db" => :sierra
    sha256 "d31ad8b842092150f18dd706d369a0fa6db7fbb41302247eac601c97785218af" => :el_capitan
    sha256 "5c9257ab10d92825e5738c0e9128876b89265095077fcde7187eee98cbe92980" => :x86_64_linux
  end

  depends_on "gettext"
  # Fix WARNING: 'makeinfo' is missing on your system.
  depends_on "texinfo" => :build unless OS.mac?

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
    ]

    args << "--program-prefix=g"
    system "./configure", *args
    system "make", "install"

    if OS.mac?
      (libexec/"gnubin").install_symlink bin/"gindent" => "indent"
      (libexec/"gnuman/man1").install_symlink man1/"gindent.1" => "indent.1"
    end
  end

  def caveats; <<~EOS
    GNU "indent" has been installed as "gindent".
    If you need to use it as "indent", you can add a "gnubin" directory
    to your PATH from your bashrc like:

        PATH="#{opt_libexec}/gnubin:$PATH"

    Additionally, you can access its man page with normal name if you add
    the "gnuman" directory to your MANPATH from your bashrc as well:

        MANPATH="#{opt_libexec}/gnuman:$MANPATH"
  EOS
  end

  test do
    indent = OS.mac? ? "gindent" : "indent"
    (testpath/"test.c").write("int main(){ return 0; }")
    system "#{bin}/#{indent}", "test.c"
    assert_equal File.read("test.c"), <<~EOS
      int
      main ()
      {
        return 0;
      }
    EOS
  end
end
