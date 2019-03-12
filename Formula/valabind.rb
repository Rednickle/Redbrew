class Valabind < Formula
  desc "Vala bindings for radare, reverse engineering framework"
  homepage "https://radare.org/"
  url "https://github.com/radare/valabind/archive/1.7.1.tar.gz"
  sha256 "b463b18419de656e218855a2f30a71051f03a9c4540254b4ceaea475fb79102e"
  revision 1
  head "https://github.com/radare/valabind.git"

  bottle do
    cellar :any
    sha256 "97118de180e5871fee96c4a8de602b626ce5240e5e8d4f7e1783f1a09c985da1" => :mojave
    sha256 "84c2f3f9fcb4216e50cf3a2f78733c4219f8e88dd38149f3b8f4c39be897b195" => :high_sierra
    sha256 "8376e0ec22d6700263cea674b53f4fdaf7dca35c04c6656df9566c24fa1121e2" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "swig"
  depends_on "vala"
  unless OS.mac?
    depends_on "bison" => :build
    depends_on "flex" => :build
  end

  patch do
    # Please remove this patch for valabind > 1.6.0.
    url "https://github.com/radare/valabind/commit/774707925962fe5865002587ef031048acbe9d89.patch?full_index=1"
    sha256 "d6a88a7c98ab0e001c4ce2d50e809ed4c4b9258954133434758d1f0c5e26f9e9"
  end

  def install
    unless OS.mac?
      # Valabind depends on the Vala code generator library during execution.
      # The `libvala` pkg-config file installed by brew isn't pointing to Vala's
      # opt_prefix so Valabind will break as soon as Vala releases a new
      # patchlevel. This snippet modifies the Makefile to point to Vala's
      # `opt_prefix` instead.
      vala = Formula["vala"]
      inreplace "Makefile", /^VALA_PKGLIBDIR=(.*$)/, "VALA_PKGLIBDIR_=\\1\nVALA_PKGLIBDIR=$(subst #{vala.prefix(vala.version)},#{vala.opt_prefix},$(VALA_PKGLIBDIR_))"
    end

    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system bin/"valabind", "--help"
  end
end
