class Mednafen < Formula
  desc "Multi-system emulator"
  homepage "http://mednafen.fobby.net/"
  url "https://mednafen.github.io/releases/files/mednafen-0.9.48.tar.xz"
  sha256 "d3cc0c838f496511946d6ea18fda5965d2b71577c610acc811835cc87d152102"

  bottle do
    sha256 "28d2204ee6d2a149c52f2e3fa5eb93df32ade953f23d55baf7b42a6dc2381c6c" => :sierra
    sha256 "b20890bbc576242c92c714a4255a264ab1a918440c65d0fba341a5d2648477bb" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "sdl"
  depends_on "libsndfile"
  depends_on :macos => :sierra # needs clock_gettime
  depends_on "gettext"

  unless OS.mac?
    depends_on "zlib"
    depends_on "linuxbrew/xorg/glu"
    depends_on "linuxbrew/xorg/mesa"
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j16" if ENV["CIRCLECI"]

    # Fix run-time crash "Assertion failed: (x == TestLLVM15470_Counter), function
    # TestLLVM15470_Sub2, file tests.cpp, line 643."
    # LLVM miscompiles some loop code with optimization
    # https://llvm.org/bugs/show_bug.cgi?id=15470
    ENV.O2

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    # Test fails on headless CI: Could not initialize SDL: No available video device
    return if ENV["CIRCLECI"] || ENV["TRAVIS"]
    cmd = "#{bin}/mednafen -dump_modules_def M >/dev/null || head -n 1 M"
    assert_equal version.to_s, shell_output(cmd).chomp
  end
end
