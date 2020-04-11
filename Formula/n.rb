class N < Formula
  desc "Node version management"
  homepage "https://github.com/tj/n"
  url "https://github.com/tj/n/archive/v6.5.1.tar.gz"
  sha256 "5833f15893b9951a9ed59487e87b6c181d96b83a525846255872c4f92f0d25dd"
  head "https://github.com/tj/n.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "cc203ce1afe1d3bf97a5c01420e506cfea9e3e57fa3511c7ad3edd4c072d4612" => :catalina
    sha256 "cc203ce1afe1d3bf97a5c01420e506cfea9e3e57fa3511c7ad3edd4c072d4612" => :mojave
    sha256 "cc203ce1afe1d3bf97a5c01420e506cfea9e3e57fa3511c7ad3edd4c072d4612" => :high_sierra
    sha256 "d193706773c7ad866d150012afde2acbf8c6fe45346c1d9f2597b68a23f0076e" => :x86_64_linux
  end

  def install
    bin.mkdir
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system bin/"n", "ls"
  end
end
