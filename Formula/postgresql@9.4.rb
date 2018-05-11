class PostgresqlAT94 < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v9.4.18/postgresql-9.4.18.tar.bz2"
  sha256 "428337f2b2f5e3ea21b8a44f88eb89c99a07a324559b99aebe777c9abdf4c4c0"

  bottle do
    sha256 "3b6142111be8016544c6033f264f4b958c67a0e55050833aa29106eef4f5375a" => :high_sierra
    sha256 "23ce9c8a6ed128d559d9c87051dd0d05a27e5548664e12e75728cf5dd3c5f51c" => :sierra
    sha256 "495fa8f166505f36671469d7c2c653853f62ff10fe5823b2d4b2be4f8832eb95" => :el_capitan
    sha256 "01d2cf942bcbe0812bfe70e9984640244ba1806ff9b36bbc24164c1127b6db6e" => :x86_64_linux
  end

  keg_only :versioned_formula

  option "without-perl", "Build without Perl support"
  if OS.mac?
    option "without-tcl", "Build without Tcl support"
  else
    option "with-tcl", "Build with Tcl support"
  end
  option "with-dtrace", "Build with DTrace support"

  deprecated_option "with-python" => "with-python@2"

  depends_on "openssl"
  depends_on "readline"
  depends_on "python@2" => :optional

  unless OS.mac?
    depends_on "libxslt"
    depends_on "perl" => :recommended # for libperl.so
    depends_on "tcl-tk" if build.with? "tcl"
    depends_on "util-linux" # for libuuid
  end

  fails_with :clang do
    build 211
    cause "Miscompilation resulting in segfault on queries"
  end

  def install
    # Fix "configure: error: readline library not found"
    if MacOS.version == :sierra || MacOS.version == :el_capitan
      ENV["SDKROOT"] = MacOS.sdk_path
    end

    ENV.prepend "LDFLAGS", "-L#{Formula["openssl"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl"].opt_include} -I#{Formula["readline"].opt_include}"
    ENV.append_to_cflags "-D_XOPEN_SOURCE"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{pkgshare}
      --docdir=#{doc}
      --enable-thread-safety
      --with-openssl
      --with-libxml
      --with-libxslt
    ]
    args += %w[
      --with-bonjour
      --with-gssapi
      --with-ldap
      --with-pam
    ] if OS.mac?

    args << "--with-perl" if build.with? "perl"
    args << "--with-python" if build.with? "python@2"

    # The CLT is required to build tcl support on 10.7 and 10.8 because tclConfig.sh is not part of the SDK
    if build.with?("tcl") && (MacOS.version >= :mavericks || MacOS::CLT.installed?)
      args << "--with-tcl"

      if File.exist?("#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework/tclConfig.sh")
        args << "--with-tclconfig=#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework"
      end
    end

    args << "--enable-dtrace" if build.with? "dtrace"
    args << "--with-uuid=e2fs"

    system "./configure", *args
    system "make", "install-world"
  end

  def post_install
    (var/"log").mkpath
    (var/name).mkpath
    unless File.exist? "#{var}/#{name}/PG_VERSION"
      system "#{bin}/initdb", "#{var}/#{name}"
    end
  end

  def caveats
    s = <<~EOS
      If builds of PostgreSQL 9 are failing and you have version 8.x installed,
      you may need to remove the previous version first. See:
        https://github.com/Homebrew/legacy-homebrew/issues/2510

      To migrate existing data from a previous major version (pre-9.3) of PostgreSQL, see:
        https://www.postgresql.org/docs/9.3/static/upgrading.html
    EOS

    if MacOS.prefer_64_bit?
      s << <<~EOS
        \nWhen installing the postgres gem, including ARCHFLAGS is recommended:
          ARCHFLAGS="-arch x86_64" gem install pg

        To install gems without sudo, see the Homebrew documentation:
          https://docs.brew.sh/Gems,-Eggs-and-Perl-Modules
      EOS
    end

    s
  end

  plist_options :manual => "pg_ctl -D #{HOMEBREW_PREFIX}/var/postgresql@9.4 start"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/postgres</string>
        <string>-D</string>
        <string>#{var}/#{name}</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/#{name}.log</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/initdb", testpath/"test"
  end
end
