class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  revision OS.mac? ? 1 : 3

  stable do
    url "https://curl.haxx.se/download/curl-7.69.0.tar.bz2"
    sha256 "668d451108a7316cff040b23c79bc766e7ed84122074e44f662b8982f2e76739"

    # The below three patches all fix critical bugs. Remove them with curl 7.69.1.
    patch do
      url "https://github.com/curl/curl/commit/8aa04e9a24932b830bc5eaf6838dea5a3329341e.patch?full_index=1"
      sha256 "77595ec475e692bd24832e0e6e98de5d68a43bf7199c632ae0443fcb932791fb"
    end

    patch do
      url "https://github.com/curl/curl/commit/e040146f22608fd92c44be2447a6505141a8a867.patch?full_index=1"
      sha256 "f4267c146592067e84eacb62cdb22e0a35636699a8237470ccaf27d68cb17a86"
    end

    patch do
      url "https://github.com/curl/curl/commit/64258bd0aa6ad23195f6be32e6febf7439ab7984.patch?full_index=1"
      sha256 "afeb69e09b3402926acd40d76f6b28d9790ac1f1e080f4eb3f2500d5aaf46971"
    end
  end

  bottle do
    sha256 "201cb204c2a8fff166af6650d5a1e5a925d77a8edacecbae27a89a98c0acdd15" => :catalina
    sha256 "b310f1da8a6d86eee7733f0c010ea324c1dbbc3cb817224425fa97fd6c7ae132" => :mojave
    sha256 "82b4720c1651a98a57a9652ea92fe4f5cd9d5cf6024660ce9acd2d384b2eacb1" => :high_sierra
  end

  pour_bottle? do
    reason "The bottle needs to be installed into #{Homebrew::DEFAULT_PREFIX} when built with OpenSSL."
    satisfy { OS.mac? || HOMEBREW_PREFIX.to_s == Homebrew::DEFAULT_PREFIX }
  end

  head do
    url "https://github.com/curl/curl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  depends_on "pkg-config" => :build
  depends_on "openssl@1.1" unless OS.mac?

  uses_from_macos "zlib"

  def install
    system "./buildconf" if build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-secure-transport
    ]

    if OS.mac?
      args << "--with-darwinssl"
      args << "--without-ca-bundle"
      args << "--without-ca-path"
    else
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl@1.1"].opt_lib}/pkgconfig"
      args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
      args << "--with-ca-bundle=#{etc}/openssl@1.1/cert.pem"
      args << "--with-ca-path=#{etc}/openssl@1.1/certs"
      args << "--disable-ares"
      args << "--disable-ldap"
    end

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "lib/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
