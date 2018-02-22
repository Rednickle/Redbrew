class Stella < Formula
  desc "Atari 2600 VCS emulator"
  homepage "https://stella-emu.github.io/"
  url "https://github.com/stella-emu/stella/releases/download/5.1.1/stella-5.1.1-src.tar.xz"
  sha256 "3de6ad86e4e881d1a23395c36c5453eb8a1160d0f3a021992fe990a009a933da"
  head "https://github.com/stella-emu/stella.git"

  bottle do
    cellar :any
    sha256 "20531655187c2cc8137714a7df420a701838192fb7cbd83d587300d1c8691471" => :high_sierra
    sha256 "2fb238f5b88ab0b154aa97ef9d2a25ca2176e1205702183b27711b928da04007" => :sierra
    sha256 "9be378753ee161c47391ce91aa9c3476df906062f6f5ad7dd57e2e8eb77d0921" => :el_capitan
    sha256 "ff66a205c2e82f608662c676b149fbeab1146cc378dbc77fb8993a6a2d934e6c" => :x86_64_linux
  end

  needs :cxx14

  depends_on :xcode => :build if OS.mac?
  depends_on "sdl2"
  depends_on "libpng"
  depends_on "zlib" unless OS.mac?
  # Stella is using c++14
  fails_with :gcc => "4.8" unless OS.mac?

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j16" if ENV["CIRCLECI"]

    sdl2 = Formula["sdl2"]
    libpng = Formula["libpng"]
    if OS.mac?
      cd "src/macosx" do
        inreplace "stella.xcodeproj/project.pbxproj" do |s|
          s.gsub! %r{(\w{24} \/\* SDL2\.framework)}, '//\1'
          s.gsub! %r{(\w{24} \/\* png)}, '//\1'
          s.gsub! /(HEADER_SEARCH_PATHS) = \(/,
                  "\\1 = (#{sdl2.opt_include}/SDL2, #{libpng.opt_include},"
          s.gsub! /(LIBRARY_SEARCH_PATHS) = ("\$\(LIBRARY_SEARCH_PATHS\)");/,
                  "\\1 = (#{sdl2.opt_lib}, #{libpng.opt_lib}, \\2);"
          s.gsub! /(OTHER_LDFLAGS) = "((-\w+)*)"/, '\1 = "-lSDL2 -lpng \2"'
        end
        xcodebuild "SYMROOT=build"
        prefix.install "build/Release/Stella.app"
        bin.write_exec_script "#{prefix}/Stella.app/Contents/MacOS/Stella"
      end
    else
      system "./configure", "--prefix=#{prefix}",
                            "--bindir=#{bin}",
                            "--with-sdl-prefix=#{sdl2.prefix}",
                            "--with-libpng-prefix=#{libpng.prefix}",
                            "--with-zlib-prefix=#{Formula["zlib"].prefix}"
      system "make", "install"
    end
  end

  test do
    assert_match /Stella version #{version}/, shell_output("#{bin}/Stella -help").strip if OS.mac?
    # Test is disabled for Linux, as it is failing with:
    # ERROR: Couldn't load settings file
    # ERROR: Couldn't initialize SDL: No available video device
    # ERROR: Couldn't create OSystem
    # ERROR: Couldn't save settings file
  end
end
