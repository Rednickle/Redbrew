class Libshout < Formula
  desc "Data and connectivity library for the icecast server"
  homepage "http://www.icecast.org/"
  url "https://downloads.xiph.org/releases/libshout/libshout-2.4.1.tar.gz"
  sha256 "f3acb8dec26f2dbf6df778888e0e429a4ce9378a9d461b02a7ccbf2991bbf24d"

  bottle do
    cellar :any
    sha256 "31b3490184bacfbacc6a537385f7ebc421ae750cd2e466f00d53dc9f78ebf948" => :high_sierra
    sha256 "a13a78cf64be826de47b9bc0430ead7ac900fa513be146ad408370d412ce3bce" => :sierra
    sha256 "691763e02e7e63b03d2d530447798351ab92d705fb1fd68cc90f9a5ccd131d53" => :el_capitan
    sha256 "3412147c3ebff685e303a54e50806ea32731f72c8b127dcc7665795ee39ff5b5" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "theora"
  depends_on "speex"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end
