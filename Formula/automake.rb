class Automake < Formula
  desc "Tool for generating GNU Standards-compliant Makefiles"
  homepage "https://www.gnu.org/software/automake/"
  url "https://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/automake/automake-1.16.1.tar.xz"
  sha256 "5d05bb38a23fd3312b10aea93840feec685bdf4a41146e78882848165d3ae921"

  bottle do
    cellar :any_skip_relocation
    sha256 "f9d2f7f913917ce686bf8dab00fe5c5f2c971038ed91b2a6ec8cd6be9efd9b31" => :high_sierra
    sha256 "f9d2f7f913917ce686bf8dab00fe5c5f2c971038ed91b2a6ec8cd6be9efd9b31" => :sierra
    sha256 "397f56ce7582b559171de62dfa772fc1a90d99bb1f03ae2f20e6824a243f7ae7" => :el_capitan
  end

  # Linux bug fix: https://github.com/Linuxbrew/homebrew-core/issues/6275
  # Function 'none' was only introduced in List::Util 1.33, so we emulate it
  patch :DATA unless OS.mac?

  keg_only :provided_until_xcode43

  depends_on "autoconf" => :run

  def install
    ENV["PERL"] = "/usr/bin/perl" if OS.mac?

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Our aclocal must go first. See:
    # https://github.com/Homebrew/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<~EOS
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      int main() { return 0; }
    EOS
    (testpath/"configure.ac").write <<~EOS
      AC_INIT(test, 1.0)
      AM_INIT_AUTOMAKE
      AC_PROG_CC
      AC_CONFIG_FILES(Makefile)
      AC_OUTPUT
    EOS
    (testpath/"Makefile.am").write <<~EOS
      bin_PROGRAMS = test
      test_SOURCES = test.c
    EOS
    system bin/"aclocal"
    system bin/"automake", "--add-missing", "--foreign"
    system "autoconf"
    system "./configure"
    system "make"
    system "./test"
  end
end

__END__
diff -bur automake-1.16/bin/automake.in  automake-1.16.new/bin/automake.in
--- automake-1.16/bin/automake.in       2018-02-26 01:13:58.000000000 +1100
+++ automake-1.16.new/bin/automake.in   2018-03-04 10:28:25.357886554 +1100
@@ -73,7 +73,8 @@
 use Automake::Language;
 use File::Basename;
 use File::Spec;
-use List::Util 'none';
+use List::Util 'reduce';
+sub none (&@) { my $code=shift; reduce { $a && !$code->(local $_ = $b) } 1, @_; }
 use Carp;

 ## ----------------------- ##
