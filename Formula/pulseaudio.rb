class Pulseaudio < Formula
  desc "Sound system for POSIX OSes"
  homepage "https://wiki.freedesktop.org/www/Software/PulseAudio/"
  url "https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-12.1.tar.xz"
  sha256 "5f5dfb5e2c376e8c974b80f93b983ed77088ade7fb8b9325a575c45aa35977f3"

  bottle do
    sha256 "1703bc9bcb2d1f9a1f3b17cf07aade8a6dba609fc3f466209b3d06c08f4b50b3" => :high_sierra
    sha256 "947bacd42d1d79b896a1fba8f06e04146f0222ffce61797b224ffe7fda4b78a8" => :sierra
    sha256 "c26f22caf001a38af9a9f738d7a6634aca5df3aaba106e4633960df1087acd54" => :el_capitan
  end

  head do
    url "https://anongit.freedesktop.org/git/pulseaudio/pulseaudio.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "intltool" => :build
    depends_on "gettext" => :build
  end

  option "with-nls", "Build with native language support"

  deprecated_option "without-speex" => "without-speexdsp"

  depends_on "pkg-config" => :build

  if build.with? "nls"
    depends_on "intltool" => :build
    depends_on "gettext" => :build
  end

  depends_on "libtool"
  depends_on "json-c"
  depends_on "libsndfile"
  depends_on "libsoxr"
  depends_on "openssl"
  depends_on "speexdsp" => :recommended
  depends_on "glib" => :optional
  depends_on "gconf" => :optional
  depends_on "gtk+3" => :optional
  depends_on "jack" => :optional

  unless OS.mac?
    depends_on "m4" => :build
    depends_on "libcap"
    depends_on "expat"

    # Depends on XML::Parser
    # Using the host's Perl interpreter to install XML::Parser fails when using brew's glibc.
    # Use brew's Perl interpreter instead.
    # See Linuxbrew/homebrew-core#8148
    depends_on "perl" => :build
    resource "XML::Parser" do
      url "https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.44.tar.gz"
      sha256 "1ae9d07ee9c35326b3d9aad56eae71a6730a73a116b9fe9e8a4758b7cc033216"
    end
  end

  fails_with :clang do
    build 421
    cause "error: thread-local storage is unsupported for the current target"
  end

  def install
    unless OS.mac?
      ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
      resources.each do |res|
        res.stage do
          system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
          system "make", "PERL5LIB=#{ENV["PERL5LIB"]}", *("CC=#{ENV.cc}" unless OS.mac?)
          system "make", "install"
        end
      end
    end

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --disable-neon-opt
      --disable-x11
    ]

    if OS.mac?
      args << "--with-mac-sysroot=#{MacOS.sdk_path})"
      args << "--with-mac-version-min=#{MacOS.version}"
    end

    args << "--disable-nls" if build.without? "nls"

    # Perl depends on gdbm.
    # If the dependency of pulseaudio on perl is build-time only,
    # pulseaudio detects and links gdbm at build-time, but cannot locate it at run-time.
    # Thus, we have to
    #  - specify not to use gdbm, or
    #  - add a dependency on gdbm if gdbm is wanted (not implemented).
    # See Linuxbrew/homebrew-core#8148
    args << "--with-database=simple" unless OS.mac?

    if build.head?
      # autogen.sh runs bootstrap.sh then ./configure
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
  end

  plist_options :manual => "pulseaudio"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/pulseaudio</string>
        <string>--start</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
  EOS
  end

  test do
    assert_match "module-sine", shell_output("#{bin}/pulseaudio --dump-modules")
  end
end
