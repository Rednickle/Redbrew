class Re2 < Formula
  desc "Alternative to backtracking PCRE-style regular expression engines"
  homepage "https://github.com/google/re2"
  url "https://github.com/google/re2/archive/2019-01-01.tar.gz"
  version "20190101"
  sha256 "bee07121ce72ce10ccacb84e49b29d091ca18d5d14d950ab7c4657a0903655db"
  head "https://github.com/google/re2.git"

  bottle do
    cellar :any
    sha256 "ef1c527710b87745d31df96a05671748c1a377f7936e94304b64fa7b7e7cd9e6" => :mojave
    sha256 "9d20a6689393ac73019a22b67c8b1fae6c40affeab7ce90d0db631e0f2a88fbb" => :high_sierra
    sha256 "06a90d1d8bfcab9a86323fc00034057cef39c66077f06664009f6eeb57cef44c" => :sierra
    sha256 "abeaa82f51489fdd54edeebc33d8a5f1f1756c7742b6f2d7ed88f44843843d10" => :x86_64_linux
  end

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    ENV.cxx11

    system "make", "install", "prefix=#{prefix}"
    MachO::Tools.change_dylib_id("#{lib}/libre2.0.0.0.dylib", "#{lib}/libre2.0.dylib") if OS.mac?
    ext = OS.mac? ? "dylib" : "so"
    lib.install_symlink "libre2.0.0.0.#{ext}" => "libre2.0.#{ext}"
    lib.install_symlink "libre2.0.0.0.#{ext}" => "libre2.#{ext}"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <re2/re2.h>
      #include <assert.h>
      int main() {
        assert(!RE2::FullMatch("hello", "e"));
        assert(RE2::PartialMatch("hello", "e"));
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11",
           "test.cpp", "-I#{include}", "-L#{lib}", "-pthread", "-lre2", "-o", "test"
    system "./test"
  end
end
