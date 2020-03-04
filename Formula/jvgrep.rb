class Jvgrep < Formula
  desc "Grep for Japanese users of Vim"
  homepage "https://github.com/mattn/jvgrep"
  url "https://github.com/mattn/jvgrep/archive/v5.8.5.tar.gz"
  sha256 "82470a9852b5cb2f093bcdbcb7c66f3d2e1ab7a8f3680e90d6944a0990a11f3d"
  head "https://github.com/mattn/jvgrep.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d1060a9bafbdaa653573e89cacc6df443f72368cf1314398a11e4509203604bc" => :catalina
    sha256 "d1060a9bafbdaa653573e89cacc6df443f72368cf1314398a11e4509203604bc" => :mojave
    sha256 "d1060a9bafbdaa653573e89cacc6df443f72368cf1314398a11e4509203604bc" => :high_sierra
    sha256 "62466745bb13eec04bac96b248591393d1985973a0001ca401b8584705bd0d15" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags", "-s -w", "-trimpath", "-o", bin/"jvgrep"
    prefix.install_metafiles
  end

  test do
    (testpath/"Hello.txt").write("Hello World!")
    system bin/"jvgrep", "Hello World!", testpath
  end
end
