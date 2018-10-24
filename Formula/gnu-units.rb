class GnuUnits < Formula
  desc "GNU unit conversion tool"
  homepage "https://www.gnu.org/software/units/"
  url "https://ftp.gnu.org/gnu/units/units-2.18.tar.gz"
  mirror "https://ftpmirror.gnu.org/units/units-2.18.tar.gz"
  sha256 "64959c231c280ceb4f3e6ae6a19b918247b6174833f7f1894704c444869c4678"

  bottle do
    sha256 "1aa452c7a4984005145a7900c5f44e899efacffa307cee4014f472cb939ff789" => :mojave
    sha256 "1c3aacea01deab09ec709f91539fe43839846d7be5f3e0a130ea1e8ae7606fff" => :high_sierra
    sha256 "3ed2c600cbc2af885b6c3d660b2a707e74cec265d94e141a62e40bb9517348c6" => :sierra
    sha256 "1006731c4af0d3893c8e2ba94f411f25c5b3aff5ca040b2de5658a87ef230552" => :x86_64_linux
  end

  if OS.mac?
    option "with-default-names", "Don't prepend 'g' to the binaries"
  else
    option "without-default-names", "Prepend 'g' to the binaries"
  end

  deprecated_option "default-names" => "with-default-names"

  depends_on "readline"

  def install
    args = ["--prefix=#{prefix}", "--with-installed-readline"]
    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"

    if build.without? "default-names"
      (libexec/"gnubin").install_symlink bin/"gunits" => "units"
      (libexec/"gnubin").install_symlink bin/"gunits_cur" => "units_cur"
      (libexec/"gnuman/man1").install_symlink man1/"gunits.1" => "units.1"
    end
  end

  test do
    units = OS.mac? ? "gunits" : "units"
    assert_equal "* 18288", shell_output("#{bin}/#{units} '600 feet' 'cm' -1").strip
  end
end
