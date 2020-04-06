class Nift < Formula
  desc "Cross-platform open source framework for managing and generating websites"
  homepage "https://nift.cc/"
  url "https://github.com/nifty-site-manager/nsm/archive/v2.3.1.tar.gz"
  sha256 "2d0f556989d4f2117b5b008f6459a1485dd25c03bfe85d0326302a0c26ffedb6"

  bottle do
    cellar :any_skip_relocation
    sha256 "99e1420ac4cac5e3086baeeb89296710958a073ad8700f07ac9eb9166c9fcd71" => :catalina
    sha256 "87acd9cf82760881144ea831a3320073b48cee89ab528ca4e844392b008de7e5" => :mojave
    sha256 "d204390326a9a6fa937cc864c96c0134ace05bfcb74681091f232e2cecfedf1a" => :high_sierra
    sha256 "3969d66ff7842408ac86f18f3fe23ce6f1537ea3aea196775f045bba3ca13cd3" => :x86_64_linux
  end

  depends_on "luajit" unless OS.mac?

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    mkdir "empty" do
      system "#{bin}/nsm", "init", ".html"
      assert_predicate testpath/"empty/output/index.html", :exist?
    end
  end
end
