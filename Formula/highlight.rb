class Highlight < Formula
  desc "Convert source code to formatted text with syntax highlighting"
  homepage "http://www.andre-simon.de/doku/highlight/en/highlight.html"
  url "http://www.andre-simon.de/zip/highlight-3.40.tar.bz2"
  sha256 "3e55fadd3f2a85f25ea995fd0e57e94e2a59fe2e3ccefe6bd896b50acadc38e3"
  revision 1
  head "https://github.com/andre-simon/highlight.git"

  bottle do
    sha256 "7e2983c2c56792522f97380ddbfd99d93e8a40f4ed5428270b7c890679c5e90e" => :high_sierra
    sha256 "013d843a52cafc3b39eab427af44595250929c74ec80b89d0071a02a43bfb39e" => :sierra
    sha256 "6fb88c3313c25802ddc3dc72db6c9d6e5aef7287bed86ee42c5319098bc37fab" => :el_capitan
    sha256 "f411935b6f8a1a7bf1acad2c485def6a1cf7f9bfde3d3613b3886cbfae356e64" => :x86_64_linux
  end

  depends_on "boost" => :build
  depends_on "pkg-config" => :build
  depends_on "lua"

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    conf_dir = etc/"highlight/" # highlight needs a final / for conf_dir
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}"
    system "make", "PREFIX=#{prefix}", "conf_dir=#{conf_dir}", "install"
  end

  test do
    system bin/"highlight", doc/"examples/highlight_pipe.php"
  end
end
