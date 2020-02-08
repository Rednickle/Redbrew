class Cpl < Formula
  desc "ISO-C libraries for developing astronomical data-reduction tasks"
  homepage "https://www.eso.org/sci/software/cpl/index.html"
  url "ftp://ftp.eso.org/pub/dfs/pipelines/libraries/cpl/cpl-7.1.2.tar.gz"
  sha256 "b6d20752420e2333e86d9a08c24a08057351a9fef97c32f5894e63fbfece463a"
  revision 3

  bottle do
    cellar :any
    sha256 "9f2525cb8eec2b2312a9b139b30b0f1ac4b1a0fe8e417f82bb31b2d4fe3c7372" => :catalina
    sha256 "ad2412ebad8b4711e1acd593a2e314c325f8def7a54d958b5adc9e65412283d8" => :mojave
    sha256 "81988a1d17cddd8d5b6d9167086ed3cf2a4ff19e295e3302beff793f2ddc3854" => :high_sierra
    sha256 "311124b6e6616708403d20fce7e67f0947869a5e1f36b87e884e67d51f8208f0" => :x86_64_linux
  end

  depends_on "cfitsio"
  depends_on "fftw"
  depends_on "wcslib"

  conflicts_with "gdal", :because => "both install cpl_error.h"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-cfitsio=#{Formula["cfitsio"].prefix}",
                          "--with-fftw=#{Formula["fftw"].prefix}",
                          "--with-wcslib=#{Formula["wcslib"].prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOF
      #include <cpl.h>
      int main(){
        cpl_init(CPL_INIT_DEFAULT);
        cpl_msg_info("hello()", "Hello, world!");
        cpl_end();
        return 0;
      }
    EOF
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-lcplcore", "-lcext", "-o", "test"
    system "./test"
  end
end
