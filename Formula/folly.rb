class Folly < Formula
  desc "Collection of reusable C++ library artifacts developed at Facebook"
  homepage "https://github.com/facebook/folly"
  url "https://github.com/facebook/folly/archive/v2020.04.13.00.tar.gz"
  sha256 "369d17a6603c1dc53db006bd5d613461b76db089bd90a85a713565c263497082"
  head "https://github.com/facebook/folly.git"

  bottle do
    cellar :any
    sha256 "ff7f87715bbf1767fd0858919cfb69de69aafcc849493ab2be173c018d3d5eca" => :catalina
    sha256 "1ba8e6e6f7cbbe85f1a21ee30f1282bbe800214b785161400868af4881a769d1" => :mojave
    sha256 "fcc9fa33a3af36663eb832a9346143548b56ccda4cd28440a507b2cd8e630610" => :high_sierra
    sha256 "8bf0f662a8ff808f3728c99c096874493e829def03bf3c99b6862f677e5e6c49" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmt"
  depends_on "gflags"
  depends_on "glog"
  depends_on "libevent"
  depends_on "lz4"
  # https://github.com/facebook/folly/issues/966
  depends_on :macos => :high_sierra if OS.mac?

  depends_on "openssl@1.1"
  depends_on "snappy"
  depends_on "xz"
  depends_on "zstd"
  unless OS.mac?
    depends_on "jemalloc"
    depends_on "python"
  end

  def install
    mkdir "_build" do
      args = std_cmake_args
      args << "-DFOLLY_USE_JEMALLOC=#{OS.mac? ? "OFF" : "ON"}"

      system "cmake", "..", *args, "-DBUILD_SHARED_LIBS=ON", ("-DCMAKE_POSITION_INDEPENDENT_CODE=ON" unless OS.mac?)
      system "make"
      system "make", "install"

      system "make", "clean"
      system "cmake", "..", *args, "-DBUILD_SHARED_LIBS=OFF"
      system "make"
      lib.install "libfolly.a", "folly/libfollybenchmark.a"
    end
  end

  test do
    (testpath/"test.cc").write <<~EOS
      #include <folly/FBVector.h>
      int main() {
        folly::fbvector<int> numbers({0, 1, 2, 3});
        numbers.reserve(10);
        for (int i = 4; i < 10; i++) {
          numbers.push_back(i * 2);
        }
        assert(numbers[6] == 12);
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++14", "test.cc", "-I#{include}", "-L#{lib}",
                    "-lfolly", "-o", "test"
    system "./test"
  end
end
