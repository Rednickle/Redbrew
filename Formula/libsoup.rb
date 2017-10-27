class Libsoup < Formula
  desc "HTTP client/server library for GNOME"
  homepage "https://live.gnome.org/LibSoup"
  url "https://download.gnome.org/sources/libsoup/2.60/libsoup-2.60.2.tar.xz"
  sha256 "7263cfe18872e2e652c196f5667e514616d9c97c861dfca82a65a55f45f0da01"

  bottle do
    sha256 "12b9c97a71c3b27aa84c191054b0175c628785095762e493f9577204b36629a3" => :high_sierra
    sha256 "4a846aa24e2b3f2b5049544098aa2de8109e3b9479c5e04ce23ff1c8067321ba" => :sierra
    sha256 "521eb03c23feaa00e3c409fe47f111e5bb5968250db5027968d919bb5d5e1cec" => :el_capitan
    sha256 "4bb883b1c52c14e22d4ba1e9b4dcc34a4f622f3b6338059efd907a79bde64869" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "glib-networking"
  depends_on "gnutls"
  depends_on "sqlite"
  depends_on "gobject-introspection"
  depends_on "vala"
  unless OS.mac?
    depends_on "libxml2"
    depends_on "krb5"
  end

  def install
    # Needed by intltool (xml::parser)
    ENV.prepend_path "PERL5LIB", "#{Formula["intltool"].libexec}/lib/perl5" unless OS.mac?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --disable-tls-check
      --enable-introspection=yes
    ]

    # ensures that the vala files remain within the keg
    inreplace "libsoup/Makefile.in",
              "VAPIDIR = @VAPIDIR@",
              "VAPIDIR = @datadir@/vala/vapi"

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libsoup/soup.h>

      int main(int argc, char *argv[]) {
        guint version = soup_get_major_version();
        return 0;
      }
    EOS
    ENV.libxml2
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/libsoup-2.4
      -D_REENTRANT
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lsoup-2.4
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
