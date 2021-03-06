class Singular < Formula
  desc "Computer algebra system for polynomial computations"
  homepage "https://www.singular.uni-kl.de/"
  url "ftp://jim.mathematik.uni-kl.de/pub/Math/Singular/SOURCES/4-1-2/singular-4.1.2p5.tar.gz"
  version "4.1.2p5"
  sha256 "743593fa17e0f87ff2ab61e87653e95c6c00a615e3a2e6fb1f0e43461473b89f"

  bottle do
    sha256 "63261fdba7c0f8131603c2ec81a6afa476f292f19873ed624c83ca8a8d2307ac" => :catalina
    sha256 "5e8be13734a20563b94510df40d32519956b64a29148ea755fd6fa2c55269744" => :mojave
    sha256 "e1d255f10d438d1811af2cc02ea56c4a01b02b70fde160185f3f1409f1d9cb45" => :high_sierra
    sha256 "9e3d611eaff2671613f220aa83832bf9aae4be7f05a44d8ac454ed302a352837" => :x86_64_linux
  end

  head do
    url "https://github.com/Singular/Sources.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "gmp"
  depends_on "mpfr"
  depends_on "ntl"
  depends_on "python"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-python=#{Formula["python"].opt_bin}/python3",
                          "CXXFLAGS=-std=c++11"
    system "make", "install"
  end

  test do
    testinput = <<~EOS
      ring r = 0,(x,y,z),dp;
      poly p = x;
      poly q = y;
      poly qq = z;
      p*q*qq;
    EOS
    assert_match "xyz", pipe_output("#{bin}/Singular", testinput, 0)
  end
end
