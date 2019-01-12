class Octave < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "https://ftp.gnu.org/gnu/octave/octave-4.4.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/octave/octave-4.4.1.tar.xz"
  sha256 "7e4e9ac67ed809bd56768fb69807abae0d229f4e169db63a37c11c9f08215f90"
  revision 4

  bottle do
    sha256 "bfb57db4884645f00deab4ed773bd7f43bea2bb0e1a1264a320fbd0b296a7555" => :mojave
    sha256 "09dd37878da04ff9deee3120e0f5a9ae663f0cadb7701e568e8df30f8d0f9f63" => :high_sierra
    sha256 "4e47c8cbc4c69819e82c0acd4043b3e825581ff0948934de69b6054d48f3704b" => :sierra
    sha256 "1322df6ec122d61080a940d6565b4484b2700a43d2b3bbdd00783f08254033dc" => :x86_64_linux
  end

  head do
    url "https://hg.savannah.gnu.org/hgweb/octave", :branch => "default", :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "icoutils" => :build
    depends_on "librsvg" => :build
  end

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on :java => ["1.6+", :build, :test]
  depends_on "pkg-config" => :build
  depends_on "arpack"
  depends_on "epstool"
  depends_on "fftw"
  depends_on "fig2dev"
  depends_on "fltk"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gcc" # for gfortran
  depends_on "ghostscript"
  depends_on "gl2ps"
  depends_on "glpk"
  depends_on "gnuplot"
  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "libsndfile"
  depends_on "libtool"
  depends_on "pcre"
  depends_on "portaudio"
  depends_on "pstoedit"
  depends_on "qhull"
  depends_on "qrupdate"
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on "sundials"
  depends_on "texinfo"
  if OS.mac?
    depends_on "veclibfort"
  else
    depends_on "curl"
    depends_on "openblas" => :recommended
  end

  depends_on "qt" => :optional

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  # If GraphicsMagick was built from source, it is possible that it was
  # done to change quantum depth. If so, our Octave bottles are no good.
  # https://github.com/Homebrew/homebrew-science/issues/2737
  def pour_bottle?
    Tab.for_name("graphicsmagick").without?("quantum-depth-32") &&
      Tab.for_name("graphicsmagick").without?("quantum-depth-8")
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc", /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/, '""'

    blas_args = []
    if build.with? "openblas"
      blas_args << "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas"
    elsif build.with? "veclibfort"
      blas_args << "--with-blas=-L#{Formula["veclibfort"].opt_lib} -lvecLibFort"
    else
      blas_args << "--with-blas=-lblas -llapack"
    end

    args = *blas_args + %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-link-all-dependencies
      --enable-shared
      --disable-static
      --disable-docs
      --with-hdf5-includedir=#{Formula["hdf5"].opt_include}
      --with-hdf5-libdir=#{Formula["hdf5"].opt_lib}
      --with-x=no
      --with-portaudio
      --with-sndfile
    ]

    args << "--without-qt" if build.without? "qt"

    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "all"

    # Avoid revision bumps whenever fftw's or gcc's Cellar paths change
    inreplace "src/mkoctfile.cc" do |s|
      s.gsub! Formula["fftw"].prefix.realpath, Formula["fftw"].opt_prefix
      s.gsub! Formula["gcc"].prefix.realpath, Formula["gcc"].opt_prefix
    end

    # Make sure that Octave uses the modern texinfo at run time
    rcfile = buildpath/"scripts/startup/site-rcfile"
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo"].opt_bin}/makeinfo\");"

    system "make", "install"
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with veclibfort
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;"
  end
end
