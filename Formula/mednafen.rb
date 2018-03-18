class Mednafen < Formula
  desc "Multi-system emulator"
  homepage "https://mednafen.github.io/"
  url "https://mednafen.github.io/releases/files/mednafen-1.21.1.tar.xz"
  sha256 "848136e4b98d5a949d7691f6596564b20d5720e7d766e93deedc7832bbee2a40"

  bottle do
    sha256 "87031d37ab517f9c55a0fe65c3ffe8584bbc4a88b856a3e4ffc4d1a0efe8785f" => :high_sierra
    sha256 "cd49bc3d5ef6c4d5346c530e99886169224e757fb19e10105e799369685f1ea9" => :sierra
    sha256 "cfe923f996d72eb25102b9b76b7c85a1e7525caa44e6ca785a465ccbbd19b83c" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "sdl2"
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
    cmd = "#{bin}/mednafen | head -n1 | grep -o '[0-9].*'"
    assert_equal version.to_s, shell_output(cmd).chomp
  end
end
