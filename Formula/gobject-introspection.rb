class GobjectIntrospection < Formula
  desc "Generate introspection data for GObject libraries"
  homepage "https://wiki.gnome.org/Projects/GObjectIntrospection"
  url "https://download.gnome.org/sources/gobject-introspection/1.64/gobject-introspection-1.64.0.tar.xz"
  sha256 "eac05a63091c81adfdc8ef34820bcc7e7778c5b9e34734d344fc9e69ddf4fc82"
  revision 1

  bottle do
    sha256 "44455cd9bb1e2e120c66b465447bea4a34af5a38b75fae44eb64f6e723fd5f4d" => :catalina
    sha256 "1d5606b9c7a59d0fc46ec7d20c85d27d1f6d3d4b15a41b23ac8ead7b74b698cf" => :mojave
    sha256 "42b61027444baaf96272c439d2e2c1bbc39400414d74a2a9f9767288c963660b" => :high_sierra
    sha256 "c23cc7f6c8350882b3da2cd5b5d08479e251caedb4dc6aae03861097215c94ce" => :x86_64_linux
  end

  depends_on "bison" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cairo"
  depends_on "glib"
  depends_on "libffi"
  depends_on "pkg-config"
  depends_on "python@3.8"

  unless OS.mac?
    depends_on "bison"
    depends_on "flex"
  end

  resource "tutorial" do
    url "https://gist.github.com/7a0023656ccfe309337a.git",
        :revision => "499ac89f8a9ad17d250e907f74912159ea216416"
  end

  def install
    Language::Python.rewrite_python_shebang(Formula["python@3.8"].opt_bin/"python3")

    ENV["GI_SCANNER_DISABLE_CACHE"] = "true"
    inreplace "giscanner/transformer.py", "/usr/share", "#{HOMEBREW_PREFIX}/share"
    inreplace "meson.build",
      "config.set_quoted('GOBJECT_INTROSPECTION_LIBDIR', join_paths(get_option('prefix'), get_option('libdir')))",
      "config.set_quoted('GOBJECT_INTROSPECTION_LIBDIR', '#{HOMEBREW_PREFIX}/lib')"

    args = %W[
      --prefix=#{prefix}
      -Dpython=#{Formula["python@3.8"].opt_bin}/python3
    ]

    mkdir "build" do
      system "meson", *args, ".."
      Language::Python.rewrite_python_shebang(Formula["python@3.8"].opt_bin/"python3")
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libffi"].opt_lib/"pkgconfig"
    resource("tutorial").stage testpath
    system "make"
    assert_predicate testpath/"Tut-0.1.typelib", :exist?
  end
end
