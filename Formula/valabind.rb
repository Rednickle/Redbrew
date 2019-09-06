class Valabind < Formula
  desc "Vala bindings for radare, reverse engineering framework"
  homepage "https://github.com/radare/valabind"
  url "https://github.com/radare/valabind/archive/1.7.1.tar.gz"
  sha256 "b463b18419de656e218855a2f30a71051f03a9c4540254b4ceaea475fb79102e"
  revision 3
  head "https://github.com/radare/valabind.git"

  bottle do
    cellar :any
    sha256 "8d671e3398e213a62ac8a3307cabf87a4f4b0469dccec7d4b6c298173e14f0c8" => :mojave
    sha256 "d181837a5f5795f5d09d0519d0a82bdd8f1c1f5b23a4ef04ff472e31d138f129" => :high_sierra
    sha256 "f3c111ef34b0c9ddd08070bcd23b79ef8df6e11df093d2ad0223c629143d0234" => :sierra
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
