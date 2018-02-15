class Fruit < Formula
  desc "Dependency injection framework for C++"
  homepage "https://github.com/google/fruit/wiki"
  url "https://github.com/google/fruit/archive/v3.1.0.tar.gz"
  sha256 "d3307e02b8c85421290fc0c748ef2f964a9313596f963ae14176f35674d7230c"

  bottle do
    cellar :any_skip_relocation
    sha256 "74f2573185454e82dc1f55eb2cd298a72d94df3b971c84d78a14778f6ccd70f8" => :high_sierra
    sha256 "30c60fc08a0129e49649deec027506f915d0b9484ef868dc53e6b9fc716dd02a" => :sierra
    sha256 "1056dd805dc9fa3ea04833f66cf6e7aedc83c277493603bf62c2a60f9a5ed872" => :el_capitan
    sha256 "7ceabf2fc5a94c072f0d116914a2c797d14ea6dd38f63e41b775a9e3564e2b9a" => :x86_64_linux
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", "-DFRUIT_USES_BOOST=False", *std_cmake_args
    system "make", "install"
    pkgshare.install "examples/hello_world/main.cpp"
  end

  test do
    cp_r pkgshare/"main.cpp", testpath
    system ENV.cxx, "main.cpp", "-I#{include}", "-L#{lib}",
           "-std=c++11", "-lfruit", "-o", "test"
    system "./test"
  end
end
