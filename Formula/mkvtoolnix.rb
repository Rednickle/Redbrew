class Mkvtoolnix < Formula
  desc "Matroska media files manipulation tools"
  homepage "https://www.bunkus.org/videotools/mkvtoolnix/"
  url "https://mkvtoolnix.download/sources/mkvtoolnix-28.2.0.tar.xz"
  sha256 "aa54b39790e619b2cfdefdd083c735503834eb05c665cd85f9b5a8383bcc5843"

  bottle do
    sha256 "867c24499ef7b380be139c5dae287548808892469479738d825348f582248185" => :mojave
    sha256 "9d8c46126e6643a5f15400dd7988d1b881a9471fa4f705d58f6b608ccba8d36c" => :high_sierra
    sha256 "1fba15cc9878269d10c4f2a529a5840ba2388c2ff7d39b64e67401b2f7ba454e" => :sierra
    sha256 "f05fb89a7e3172053da1f7c96d241daa17c83fc45976f39ba26ab46e6dcc1610" => :x86_64_linux
  end

  head do
    url "https://gitlab.com/mbunkus/mkvtoolnix.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-qt", "Build with Qt GUI"

  deprecated_option "with-qt5" => "with-qt"

  depends_on "docbook-xsl" => :build
  depends_on "pkg-config" => :build
  depends_on "pugixml" => :build
  depends_on "ruby" => :build if MacOS.version <= :mountain_lion || !OS.mac?
  depends_on "boost"
  depends_on "flac"
  depends_on "libebml"
  depends_on "libmagic"
  depends_on "libmatroska"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "gettext" => OS.mac? ? :optional : :recommended
  depends_on "qt" => :optional
  depends_on "cmark" if build.with? "qt"
  depends_on "libxslt" => :build unless OS.mac? # for xsltproc

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j4" if ENV["CIRCLECI"]

    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog" unless OS.mac?

    ENV.cxx11

    features = %w[flac libmagic libogg libvorbis libebml libmatroska]

    extra_includes = ""
    extra_libs = ""
    features.each do |feature|
      extra_includes << "#{Formula[feature].opt_include};"
      extra_libs << "#{Formula[feature].opt_lib};"
    end
    extra_includes.chop!
    extra_libs.chop!

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-boost=#{Formula["boost"].opt_prefix}
      --with-docbook-xsl-root=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
      --with-extra-includes=#{extra_includes}
      --with-extra-libs=#{extra_libs}
    ]

    if build.with?("qt")
      qt = Formula["qt"]

      args << "--with-moc=#{qt.opt_bin}/moc"
      args << "--with-uic=#{qt.opt_bin}/uic"
      args << "--with-rcc=#{qt.opt_bin}/rcc"
      args << "--enable-qt"
    else
      args << "--disable-qt"
    end

    system "./autogen.sh" if build.head?

    system "./configure", *args

    system "rake", *("--trace" if ENV["CIRCLECI"]), "-j#{ENV.make_jobs}"
    system "rake", "install"
  end

  test do
    mkv_path = testpath/"Great.Movie.mkv"
    sub_path = testpath/"subtitles.srt"
    sub_path.write <<~EOS
      1
      00:00:10,500 --> 00:00:13,000
      Homebrew
    EOS

    system "#{bin}/mkvmerge", "-o", mkv_path, sub_path
    system "#{bin}/mkvinfo", mkv_path
    system "#{bin}/mkvextract", "tracks", mkv_path, "0:#{sub_path}"
  end
end
