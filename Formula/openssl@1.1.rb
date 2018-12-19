class OpensslAT11 < Formula
  desc "Cryptography and SSL/TLS Toolkit"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-1.1.1a.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/openssl@1.1--1.1.1a.tar.gz"
  mirror "https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.1.1a.tar.gz"
  sha256 "fc20130f8b7cbd2fb918b2f14e2f429e109c31ddd0fb38fc5d71d9ffed3f9f41"
  version_scheme 1

  bottle do
    sha256 "802fef5cc7072a3dc6c1f15898d9f028d7bd32c659e93a354545e719f54a2456" => :mojave
    sha256 "29ff522cbd3509b4f881643d2dfdec78396d41f8858d7d308d59f2e3b1839aa1" => :high_sierra
    sha256 "af76397790ce9cb571a8e0bd1014a90a47ed1c05b5ee6727a2f6796ebdb95365" => :sierra
    sha256 "c153b05e49ef98fa890dfead369799e7451d30b4361eb91d655c6adff86b2412" => :x86_64_linux
  end

  keg_only :provided_by_macos,
    "openssl/libressl is provided by macOS so don't link an incompatible version"

  resource "cacert" do
    # homepage "http://curl.haxx.se/docs/caextract.html"
    url "https://curl.haxx.se/ca/cacert-2017-01-18.pem"
    mirror "http://cdn.rawgit.com/sjackman/e4066d2cb6b45fbb6d213e676cb109d0/raw/58964378cb5eefe96cba245ef863c57fb2b480e0/cacert-2017-01-18.pem"
    sha256 "e62a07e61e5870effa81b430e1900778943c228bd7da1259dd6a955ee2262b47"
  end unless OS.mac?

  # Only needs 5.10 to run, but needs >5.13.4 to run the testsuite.
  # https://github.com/openssl/openssl/blob/4b16fa791d3ad8/README.PERL
  # The MacOS ML tag is same hack as the way we handle most :python deps.
  depends_on "perl" if MacOS.version <= :mountain_lion

  # SSLv2 died with 1.1.0, so no-ssl2 no longer required.
  # SSLv3 & zlib are off by default with 1.1.0 but this may not
  # be obvious to everyone, so explicitly state it for now to
  # help debug inevitable breakage.
  def configure_args; %W[
    --prefix=#{prefix}
    --openssldir=#{openssldir}
    no-ssl3
    no-ssl3-method
    no-zlib
    #{[ENV.cppflags, ENV.cflags, ENV.ldflags].join(" ").strip unless OS.mac?}
  ]
  end

  def install
    # This could interfere with how we expect OpenSSL to build.
    ENV.delete("OPENSSL_LOCAL_CONFIG_DIR")

    # This ensures where Homebrew's Perl is needed the Cellar path isn't
    # hardcoded into OpenSSL's scripts, causing them to break every Perl update.
    # Whilst our env points to opt_bin, by default OpenSSL resolves the symlink.
    if which("perl") == Formula["perl"].opt_bin/"perl"
      ENV["PERL"] = Formula["perl"].opt_bin/"perl"
    end

    if MacOS.prefer_64_bit? && OS.mac?
      arch_args = %w[darwin64-x86_64-cc enable-ec_nistp_64_gcc_128]
    elsif MacOS.prefer_64_bit? && OS.linux?
      arch_args = %w[linux-x86_64]
    elsif OS.mac?
      arch_args = %w[darwin-i386-cc]
    elsif OS.linux?
      arch_args = %w[linux-generic32]
    end

    ENV.deparallelize
    system "perl", "./Configure", *(configure_args + arch_args)
    system "make"
    system "make", "test" if OS.mac?
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
    # See https://github.com/Linuxbrew/homebrew-core/pull/8891
    system "make", "test" if build.with?("test") && !OS.mac?
  end

  def openssldir
    etc/"openssl@1.1"
  end

  def post_install
    unless OS.mac?
      # Download and install cacert.pem from curl.haxx.se
      cacert = resource("cacert")
      rm_f openssldir/"cert.pem"
      filename = Pathname.new(cacert.url).basename
      openssldir.install cacert.files(filename => "cert.pem")
      return
    end

    keychains = %w[
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
    certs = certs_list.scan(
      /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m,
    )

    valid_certs = certs.select do |cert|
      IO.popen("#{bin}/openssl x509 -inform pem -checkend 0 -noout >/dev/null", "w") do |openssl_io|
        openssl_io.write(cert)
        openssl_io.close_write
      end

      $CHILD_STATUS.success?
    end

    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write(valid_certs.join("\n") << "\n")
  end

  def caveats; <<~EOS
    A CA file has been bootstrapped using certificates from the system
    keychain. To add additional certificates, place .pem files in
      #{openssldir}/certs

    and run
      #{opt_bin}/c_rehash
  EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    assert_predicate HOMEBREW_PREFIX/"etc/openssl@1.1/openssl.cnf", :exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system bin/"openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
