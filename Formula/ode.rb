class Ode < Formula
  desc "Simulating articulated rigid body dynamics"
  homepage "https://www.ode.org/"
  url "https://bitbucket.org/odedevs/ode/downloads/ode-0.16.1.tar.gz"
  sha256 "b228acad81f33781d53eaf313437cc5d6f66aec5a4e56c515fc1b2d51e6e8eba"
  head "https://bitbucket.org/odedevs/ode/", :using => :hg

  bottle do
    cellar :any_skip_relocation
    sha256 "52166ed37f90857e9709d01acf6f3584583ea744572fc3e75edce902515e2575" => :catalina
    sha256 "709bab4820a1c67a426e89e3fdc2839c04f57350260c783c6ceb05f2af6c23ea" => :mojave
    sha256 "b5d9873c81f9c5ad4ebae396568dfb4476d688a94df04b7cb53b80646ed07357" => :high_sierra
    sha256 "70eeb1538c7bce86079da52fd1b9992304fdd73e261815c212a864a974fdf94c" => :x86_64_linux
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libccd"

  def install
    inreplace "bootstrap", "libtoolize", "glibtoolize"
    system "./bootstrap"

    system "./configure", "--prefix=#{prefix}",
                          "--enable-libccd",
                          "--enable-shared",
                          "--disable-static",
                          "--enable-double-precision"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <ode/ode.h>
      int main() {
        dInitODE();
        dCloseODE();
        return 0;
      }
    EOS
    std = OS.mac? ? "-lc++" : "-lstdc++"
    system ENV.cc, "test.cpp", "-I#{include}/ode", "-L#{lib}", "-lode",
                   "-L#{Formula["libccd"].opt_lib}", "-lccd",
                   *("-lm" unless OS.mac?),
                   std, *("-lpthread" unless OS.mac?), "-o", "test"
    system "./test"
  end
end
