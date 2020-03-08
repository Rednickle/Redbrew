class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "https://wiki.dlang.org/LDC"
  url "https://github.com/ldc-developers/ldc/releases/download/v1.20.1/ldc-1.20.1-src.tar.gz"
  sha256 "2b21dfffb6efd2c2158bc83422765335aae34b709ebdc406bb026c21967a1aaf"
  head "https://github.com/ldc-developers/ldc.git", :shallow => false

  bottle do
    sha256 "122d9a37cccbd671d223a2ce683ad141489633d2f11fa8f662635f6ba4a49027" => :catalina
    sha256 "67f9bdd412e9ee9e6864f52ae5b52358a01b93de359fe8aad4b9d7bed73a572a" => :mojave
    sha256 "7945dba30bfac0ced442b69a46a477593ee04e3b3f28cc6fdb56b94f58e94706" => :high_sierra
    sha256 "f422d9aeb3a6be820e49e55a342372a8bc2b08c43798331df374309ecb7774e7" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "llvm"

  unless OS.mac?
    depends_on "pkg-config" => :build
    depends_on "libxml2" => :build
  end

  resource "ldc-bootstrap" do
    if OS.mac?
      url "https://github.com/ldc-developers/ldc/releases/download/v1.20.1/ldc2-1.20.1-osx-x86_64.tar.xz"
      version "1.20.1"
      sha256 "b0e711b97d7993ca77fed0f49a7d2cf279249406d46e9cf005dd77d5a4e23956"
    else
      url "https://github.com/ldc-developers/ldc/releases/download/v1.20.1/ldc2-1.20.1-linux-x86_64.tar.xz"
      version "1.20.1"
      sha256 "2185802dcabb89e516f904ee7c4c313dcf5784bb1d15cc8e674075455b1d0b6b"
    end
  end

  def install
    # Fix the error:
    # CMakeFiles/LDCShared.dir/build.make:68: recipe for target 'dmd2/id.h' failed
    ENV.deparallelize unless OS.mac?

    ENV.cxx11
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    # Fix ldc-bootstrap/bin/ldmd2: error while loading shared libraries: libxml2.so.2
    ENV.prepend_path "LD_LIBRARY_PATH", Formula["libxml2"].lib

    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-bootstrap/bin/ldmd2
      ]

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<~EOS
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS
    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    # Fix Error: The LLVMgold.so plugin (needed for LTO) was not found.
    if OS.mac?
      system bin/"ldc2", "-flto=thin", "test.d"
      assert_match "Hello, world!", shell_output("./test")
      system bin/"ldc2", "-flto=full", "test.d"
      assert_match "Hello, world!", shell_output("./test")
    end
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
