class Nghttp2 < Formula
  desc "HTTP/2 C Library"
  homepage "https://nghttp2.org/"
  url "https://github.com/nghttp2/nghttp2/releases/download/v1.35.1/nghttp2-1.35.1.tar.xz"
  sha256 "9b7f5b09c3ca40a46118240bf476a5babf4bd93a1e4fde2337c308c4c5c3263a"

  bottle do
    sha256 "3df6011e98f13af091fcc9e4c759d9e9662ee4d9a863d88284e17b461c94be92" => :mojave
    sha256 "9c21365ecf3717afe8fda8307c8b80902d7b1f24275e45b8c8458ecc5e42560c" => :high_sierra
    sha256 "cb7ca00e18e43bab469ae685713bf43bd56067cd8395ad0c5921a4c9343726b9" => :sierra
    sha256 "18099e9851d23f9b066d720731d55c44837d3b5785b159149ac99ea48c3bc33e" => :x86_64_linux
  end

  head do
    url "https://github.com/nghttp2/nghttp2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "cunit" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build
  depends_on "c-ares"
  depends_on "jansson"
  depends_on "jemalloc"
  depends_on "libev"
  depends_on "libevent"
  depends_on "libxml2" if MacOS.version <= :lion
  depends_on "openssl"

  resource "Cython" do
    url "https://files.pythonhosted.org/packages/f0/f8/7f406aac4c6919d5a4ce16509bbe059cd256e9ad94bae5ccac14094b7c51/Cython-0.29.1.tar.gz"
    sha256 "18ab7646985a97e02cee72e1ddba2e732d4931d4e1732494ff30c5aa084bfb97"
  end

  patch do
    # Fix: shrpx_api_downstream_connection.cc:57:3: error: array must be initialized with a brace-enclosed initializer
    url "https://gist.githubusercontent.com/iMichka/5dda45fbad3e70f52a6b4e7dfd382969/raw/19797e17926922bdd1ef21a47e162d8be8e2ca65/nghttp2?full_index=1"
    sha256 "0759d448d4b419911c12fa7d5cbf1df2d6d41835c9077bf3accf9eac58f24f12"
  end

  # https://github.com/tatsuhiro-t/nghttp2/issues/125
  # Upstream requested the issue closed and for users to use gcc instead.
  # Given this will actually build with Clang with cxx11, just use that.
  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    ENV.cxx11

    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --enable-app
      --disable-python-bindings
    ]

    # requires thread-local storage features only available in 10.11+
    args << "--disable-threads" if MacOS.version < :el_capitan
    args << "--with-xml-prefix=/usr" if MacOS.version > :lion

    system "autoreconf", "-ivf" if build.head?
    system "./configure", *args
    system "make"
    # Fails on Linux:
    system "make", "check" if OS.mac?
    system "make", "install"
  end

  test do
    system bin/"nghttp", "-nv", "https://nghttp2.org"
  end
end
