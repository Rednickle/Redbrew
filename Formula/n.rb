class N < Formula
  desc "Node version management"
  homepage "https://github.com/tj/n"
  url "https://github.com/tj/n/archive/v6.4.0.tar.gz"
  sha256 "580ea6a41f5a1cdbc7ef4a64c45f1a48d97e1e173ae18457fd980bc75dde3c3a"
  head "https://github.com/tj/n.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c608f69007a46cd4c475616fa8165ed65fe3472bd82b73485760fbd085ee8b5d" => :catalina
    sha256 "c608f69007a46cd4c475616fa8165ed65fe3472bd82b73485760fbd085ee8b5d" => :mojave
    sha256 "c608f69007a46cd4c475616fa8165ed65fe3472bd82b73485760fbd085ee8b5d" => :high_sierra
    sha256 "0d201b0ca383a2779217026c3668844a18c914d238a0c92e0f8ef4a9483ce4a2" => :x86_64_linux
  end

  def install
    bin.mkdir
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system bin/"n", "ls"
  end
end
