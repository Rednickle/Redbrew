class N < Formula
  desc "Node version management"
  homepage "https://github.com/tj/n"
  url "https://github.com/tj/n/archive/v6.5.0.tar.gz"
  sha256 "7034a3563eba5d1093884f1699a0587ac3e82782590ba0875205177ce0cf426e"
  head "https://github.com/tj/n.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "22ec6a5836ebdd491cd8bfbf1b1f2d0b55c29305dc665af799aeb109ddb99b45" => :catalina
    sha256 "22ec6a5836ebdd491cd8bfbf1b1f2d0b55c29305dc665af799aeb109ddb99b45" => :mojave
    sha256 "22ec6a5836ebdd491cd8bfbf1b1f2d0b55c29305dc665af799aeb109ddb99b45" => :high_sierra
    sha256 "4ee5535f97bcdde51aa35285fdec7dfcc9be96b3f6f4e0e0b0dcda13dbdbc9c4" => :x86_64_linux
  end

  def install
    bin.mkdir
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system bin/"n", "ls"
  end
end
