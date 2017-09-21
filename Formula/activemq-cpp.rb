class ActivemqCpp < Formula
  desc "C++ API for message brokers such as Apache ActiveMQ"
  homepage "https://activemq.apache.org/cms/index.html"
  url "https://www.apache.org/dyn/closer.cgi?path=activemq/activemq-cpp/3.9.4/activemq-cpp-library-3.9.4-src.tar.bz2"
  sha256 "6505137fd4835a388b5ddecf6a96a62abd01b6d80f124e95dc2076127f4a84d3"

  bottle do
    cellar :any
    sha256 "eda1e1feb50e5ffdceb93e3161eab96b389aaa65d64961c6803406176c89f198" => :sierra
    sha256 "799696b515fbff76de2277327d074dc96b74e676df72aa347b23eee12ffbc03b" => :el_capitan
    sha256 "87d76f6f4e2c6f8c6081f3308a8724b3ed47ae3b0b184386893bd65715b45a98" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "openssl"
  depends_on "apr" unless OS.mac?

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/activemqcpp-config", "--version"
  end
end
