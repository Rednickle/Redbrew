class Binutils < Formula
  desc "FSF/GNU ld, ar, readelf, etc. for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.29.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.29.1.tar.gz"
  sha256 "0d9d2bbf71e17903f26a676e7fba7c200e581c84b8f2f43e72d875d0e638771c"

  bottle do
    cellar :any if OS.linux?
    sha256 "8b09492986a9dc598763dacd168c6e30508e39fb6c61864e78e9bf8368d77563" => :high_sierra
    sha256 "274240a3aa74644d55054f45e26bc4242197cb514ae4817c128f194dc7b97901" => :sierra
    sha256 "e7e5167576c31a03bdc517ba46f28e8a0dc49531b004c96dd1598418f4dce8aa" => :el_capitan
    sha256 "a641cb5b69d2640167c6182cdcdf58f4999542b634d6d86a2825d49a8d006515" => :x86_64_linux # glibc 2.5
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
