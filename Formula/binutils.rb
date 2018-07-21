class Binutils < Formula
  desc "FSF/GNU ld, ar, readelf, etc. for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.gz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.31.tar.gz"
  sha256 "5a9de9199f22ca7f35eac378f93c45ead636994fc59f3ac08f6b3569f73fcf6f"

  bottle do
    sha256 "b837e47aa271d10ca2dd8efb736126adb01099c6fbaa59f770db21519ab9bcb9" => :high_sierra
    sha256 "5d622c2ec7ff213c0b72d7662d18a63f1b83c93d4f87d8a961a1314ac0cbb8ec" => :sierra
    sha256 "0e7dff88984a72de63547572ff56df1e236b47ccca919f065d74853913c16042" => :el_capitan
    sha256 "c2b38e75ce757671c0ac41d805bfb3cdf252ca3a5afea6a1e40dd54a84eb422f" => :x86_64_linux # glibc 2.12
  end

  # No --default-names option as it interferes with Homebrew builds.
  option "with-default-names", "Do not prepend 'g' to the binary" if OS.linux?
  option "without-gold", "Do not build the gold linker" if OS.linux?

  depends_on "zlib" => :recommended unless OS.mac?

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          ("--program-prefix=g" if build.without? "default-names"),
                          ("--with-sysroot=/" if OS.linux?),
                          "--enable-deterministic-archives",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--mandir=#{man}",
                          "--disable-werror",
                          "--enable-interwork",
                          "--enable-multilib",
                          "--enable-64-bit-bfd",
                          ("--enable-gold" if build.with? "gold"),
                          ("--enable-plugins" if OS.linux?),
                          "--enable-targets=all"
    system "make"
    system "make", "install"
    bin.install_symlink "ld.gold" => "gold" if build.with? "gold"

    # Reduce the size of the bottle.
    system "strip", *Dir[bin/"*", lib/"*.a"] unless OS.mac?
  end

  test do
    size = build.with?("default-names") ? "size" : "gsize"
    assert_match "text", shell_output("#{bin}/#{size} #{bin}/#{size}")
  end
end
