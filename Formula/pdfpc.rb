class Pdfpc < Formula
  desc "Presenter console with multi-monitor support for PDF files"
  homepage "https://pdfpc.github.io/"
  url "https://github.com/pdfpc/pdfpc/archive/v4.0.7.tar.gz"
  sha256 "25d5aa2cce344f1554f1f45a7c1f636576587cfd553d75d704e0c95ae3b2a503"
  head "https://github.com/pdfpc/pdfpc.git"

  bottle do
    sha256 "69d500397103455b3fc340d6b84543e3025a81a81076f76b74370f1c9870446b" => :high_sierra
    sha256 "a4be07cc9af776e368fff59f405cc1ea3d733ab071350cb6fd7825616a214a97" => :sierra
    sha256 "cafe2481dfeece9e53a014cbcb30ba43e0251f862317a78860d0594ee2b43d04" => :el_capitan
    sha256 "985e6a441dd32125a8e73654b5d07a8c69e7f04c2ab8d6f0a57d2573a9d64844" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "vala" => :build
  depends_on "gtk+3"
  depends_on "libgee"
  depends_on "librsvg"
  depends_on "poppler"

  def install
    system "cmake", ".", "-DMOVIES=off", *std_cmake_args
    system "make", "install"
  end

  test do
    system "#{bin}/pdfpc", "--version"
  end
end
