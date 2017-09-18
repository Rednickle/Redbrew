class Zstd < Formula
  desc "Zstandard is a real-time compression algorithm"
  homepage "http://zstd.net/"
  url "https://github.com/facebook/zstd/archive/v1.3.1.tar.gz"
  sha256 "312fb9dc75668addbc9c8f33c7fa198b0fc965c576386b8451397e06256eadc6"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    prefix "/home/linuxbrew/.linuxbrew"
    cellar :any
    sha256 "b2021d43b1a39c9405a7976099817ceb7ce7b2f23ede232fbeed840ee104ac3f" => :high_sierra
    sha256 "8ed5d6634d35dabef86531e168f7b42aee4e75e3eb373e4cc1ac68f160f26a2d" => :sierra
    sha256 "ebb20d76a07b95d0771ae66b338fdd7e47f6bb4e7a49e8fd1ec882b91d10c762" => :el_capitan
    sha256 "68dcd8dd4fa5f5a88c19d1a1cf8339c17723baef2554895063ef2afaf80774ef" => :yosemite
    sha256 "8028e9b692dd03b96a4b059dabe819fde4ee749ed36081bfb2338d8c0472a088" => :x86_64_linux # glibc 2.19
  end

  option "without-pzstd", "Build without parallel (de-)compression tool"

  depends_on "cmake" => :build
  depends_on "zlib" unless OS.mac?

  def install
    system "make", "install", "PREFIX=#{prefix}/"

    if build.with? "pzstd"
      system "make", "-C", "contrib/pzstd", "googletest"
      system "make", "-C", "contrib/pzstd", "PREFIX=#{prefix}"
      bin.install "contrib/pzstd/pzstd"
    end
  end

  test do
    assert_equal "hello\n",
      pipe_output("#{bin}/zstd | #{bin}/zstd -d", "hello\n", 0)

    if build.with? "pzstd"
      assert_equal "hello\n",
        pipe_output("#{bin}/pzstd | #{bin}/pzstd -d", "hello\n", 0)
    end
  end
end
