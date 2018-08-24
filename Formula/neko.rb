class Neko < Formula
  desc "High-level, dynamically typed programming language"
  homepage "https://nekovm.org/"
  url "https://github.com/HaxeFoundation/neko/archive/v2-2-0/neko-2.2.0.tar.gz"
  sha256 "cf101ca05db6cb673504efe217d8ed7ab5638f30e12c5e3095f06fa0d43f64e3"
  revision 5
  head "https://github.com/HaxeFoundation/neko.git"

  bottle do
    sha256 "ce8fdd0a4d8390fba3b3d36ceaae29aa173d4221507b32c5d1755b08c000ff90" => :mojave
    sha256 "a1fa4028cc7485f7f1dcbb0b587e3c30b1d52ea7cc78e9fe7c1a4f74a72d0813" => :high_sierra
    sha256 "32724bad0333f9d3c9d97ef095cda5a401d177949e522d63148c5f73852d1904" => :sierra
    sha256 "2a526fb7bf64537f71d410fd757d1c0291c3e0105f5db8aa7bed878eb5914edd" => :el_capitan
    sha256 "e299ed578b375e02b25e0117635768fedca1121bdf1b2fda2fb39b565d0b4077" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "mbedtls"
  depends_on "bdw-gc"
  depends_on "pcre"
  depends_on "openssl"
  unless OS.mac?
    depends_on "apr"
    depends_on "apr-util"
    depends_on "httpd"
    # On mac, neko uses carbon. On Linux it uses gtk2
    depends_on "gtk+"
    depends_on "pango"
    depends_on "sqlite"
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j1" if ENV["CIRCLECI"]

    args = std_cmake_args
    unless OS.mac?
      args << "-DAPR_LIBRARY=#{Formula["apr"].libexec}/lib"
      args << "-DAPR_INCLUDE_DIR=#{Formula["apr"].libexec}/include/apr-1"
      args << "-DAPRUTIL_LIBRARY=#{Formula["apr-util"].libexec}/lib"
      args << "-DAPRUTIL_INCLUDE_DIR=#{Formula["apr-util"].libexec}/include/apr-1"
    end

    # Let cmake download its own copy of MariaDBConnector during build and statically link it.
    # It is because there is no easy way to define we just need any one of mariadb, mariadb-connector-c,
    # mysql, and mysql-connector-c.
    system "cmake", ".", "-G", "Ninja", "-DSTATIC_DEPS=MariaDBConnector",
           "-DRELOCATABLE=OFF", "-DRUN_LDCONFIG=OFF", *args
    system "ninja", "install"
  end

  def caveats
    s = ""
    if HOMEBREW_PREFIX.to_s != "/usr/local"
      s << <<~EOS
        You must add the following line to your .bashrc or equivalent:
          export NEKOPATH="#{HOMEBREW_PREFIX}/lib/neko"
      EOS
    end
    s
  end

  test do
    ENV["NEKOPATH"] = "#{HOMEBREW_PREFIX}/lib/neko"
    system "#{bin}/neko", "-version"
  end
end
