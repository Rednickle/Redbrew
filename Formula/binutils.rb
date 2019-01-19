class Binutils < Formula
  desc "GNU binary tools for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.31.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.31.1.tar.gz"
  sha256 "e88f8d36bd0a75d3765a4ad088d819e35f8d7ac6288049780e2fefcad18dde88"
  revision 2

  # binutils is portable.
  bottle do
    cellar :any
    sha256 "dbe26381158b6fe4c597761babd3e3057353f59fa1b20cd73842f651d02f37da" => :mojave
    sha256 "fe41922c19581745c04cec1d4d91332111a18c5a160852478d301f6735753a2a" => :high_sierra
    sha256 "983abea2ac000ceb1deb4a87088ffbada2f6047d904aa16c9ad2e56f3a363516" => :sierra
    sha256 "cef382f33ee1b898811b2a49015ac51d398bd7b6e0fbd3d119dbaa739cefd4fe" => :x86_64_linux # glibc 2.12
  end

  if OS.mac?
    keg_only :provided_by_macos,
             "because Apple provides the same tools and binutils is poorly supported on macOS"
  end

  unless OS.mac?
    option "without-gold", "Do not build the gold linker"

    depends_on "zlib" => :recommended unless OS.mac?
  end

  # Adds support for macOS 10.14's new load commands.
  # Will be in the next release.
  # https://github.com/Homebrew/homebrew-core/issues/32516
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/91dc37fa4609cf1d040b5ede9f2eb971f3730597/binutils/add_mach_o_command.patch"
    sha256 "abb053663a56c5caef35685ee60badf57e321b18f308e7cbd11626b48c876e8c"
  end if OS.mac?

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          ("--with-sysroot=/" unless OS.mac?),
                          "--enable-deterministic-archives",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--mandir=#{man}",
                          "--disable-werror",
                          "--enable-interwork",
                          "--enable-multilib",
                          "--enable-64-bit-bfd",
                          ("--enable-gold" if build.with? "gold"),
                          ("--enable-plugins" unless OS.mac?),
                          "--enable-targets=all"
    system "make"
    system "make", "install"
    bin.install_symlink "ld.gold" => "gold" if build.with? "gold"

    Dir["#{bin}/*"].each do |f|
      bin.install_symlink f => "g" + File.basename(f)
    end if OS.mac?

    # Reduce the size of the bottle.
    system "strip", *Dir[bin/"*", lib/"*.a"] unless OS.mac?
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/strings #{bin}/strings")
  end
end
