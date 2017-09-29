class AutoconfArchive < Formula
  desc "Collection of over 500 reusable autoconf macros"
  homepage "https://savannah.gnu.org/projects/autoconf-archive/"
  url "https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-2017.09.28.tar.xz"
  mirror "https://ftpmirror.gnu.org/autoconf-archive/autoconf-archive-2017.09.28.tar.xz"
  sha256 "5c9fb5845b38b28982a3ef12836f76b35f46799ef4a2e46b48e2bd3c6182fa01"

  bottle do
    cellar :any_skip_relocation
    sha256 "296fc393577638f777d8b9eb49660964e0e6a1134cb070c402de0f085c0fb8f4" => :high_sierra
    sha256 "296fc393577638f777d8b9eb49660964e0e6a1134cb070c402de0f085c0fb8f4" => :sierra
    sha256 "296fc393577638f777d8b9eb49660964e0e6a1134cb070c402de0f085c0fb8f4" => :el_capitan
    sha256 "f0e6c46ac79e479e3513bbca370b7ec623b23452834ea68131c254897b5333f0" => :x86_64_linux
  end

  # autoconf-archive is useless without autoconf
  depends_on "autoconf" => :run

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.m4").write <<-EOS.undent
      AC_INIT(myconfig, version-0.1)
      AC_MSG_NOTICE([Hello, world.])

      m4_include([#{share}/aclocal/ax_have_select.m4])

      # from https://www.gnu.org/software/autoconf-archive/ax_have_select.html
      AX_HAVE_SELECT(
        [AX_CONFIG_FEATURE_ENABLE(select)],
        [AX_CONFIG_FEATURE_DISABLE(select)])
      AX_CONFIG_FEATURE(
        [select], [This platform supports select(7)],
        [HAVE_SELECT], [This platform supports select(7).])
    EOS

    system "#{Formula["autoconf"].bin}/autoconf", "test.m4"
  end
end
