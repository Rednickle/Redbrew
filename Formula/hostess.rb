class Hostess < Formula
  desc "Idempotent command-line utility for managing your /etc/hosts file"
  homepage "https://github.com/cbednarski/hostess"
  url "https://github.com/cbednarski/hostess/archive/v0.5.0.tar.gz"
  sha256 "38eba91ca471f76533a169c39048b7aad0c611352a3a5d3855f4341f04574b74"
  head "https://github.com/cbednarski/hostess.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "6a9d9913afdfdc168e8cde3851e4d3aee36a3f29cbb37c7eee553146b5e4c87c" => :catalina
    sha256 "04ea74921e0739da95c77825f1e7c1ba95b045ad7ed560dc236cf18ff66dbf09" => :mojave
    sha256 "a4ee18464f1ae186c1281dc17a3ed6a65c1d7ffd585e97cdf4d1d872e4a5575d" => :high_sierra
    sha256 "f95cb67c69ccfe53b6fc0c03899dbf3a948ac34d020853c8221332832118ec5d" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags", "-s -w -X main.version=#{version}", "-o", bin/"hostess"
  end

  test do
    assert_match "localhost", shell_output("#{bin}/hostess ls 2>&1")
  end
end
