class Bitcoin < Formula
  desc "Decentralized, peer to peer payment network"
  homepage "https://bitcoin.org/"
  url "https://bitcoin.org/bin/bitcoin-core-0.16.0/bitcoin-0.16.0.tar.gz"
  sha256 "8cbec0397d932cab7297a8c23c918392f6eebd410646b4b954787de9f4a3ee40"
  revision 2

  bottle do
    cellar :any
    sha256 "bb289643030658910e8feebf403d70b93b2a81c3229db2382fed30930506b468" => :x86_64_linux
  end

  head do
    url "https://github.com/bitcoin/bitcoin.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "berkeley-db@4"
  depends_on "boost"
  depends_on "libevent"
  depends_on "miniupnpc"
  depends_on "openssl"
  depends_on "bsdmainutils" => :build unless OS.mac? # `hexdump` from bsdmainutils required to compile tests
  depends_on "zeromq"

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j4 -l2.5" if ENV["CIRCLECI"]

    if MacOS.version == :el_capitan && MacOS::Xcode.installed? &&
       MacOS::Xcode.version >= "8.0"
      ENV.delete("SDKROOT")
    end

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-boost-libdir=#{Formula["boost"].opt_lib}",
                          "--prefix=#{prefix}"
    system "make", "install"
    pkgshare.install "share/rpcauth"
  end

  plist_options :manual => "bitcoind"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/bitcoind</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/test_bitcoin"
  end
end
