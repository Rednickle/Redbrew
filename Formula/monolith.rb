class Monolith < Formula
  desc "CLI tool for saving complete web pages as a single HTML file"
  homepage "https://github.com/Y2Z/monolith"
  url "https://github.com/Y2Z/monolith/archive/v2.2.2.tar.gz"
  sha256 "224ef6cc7fbde12b3d0d6f0b6758ada40848423e707af0a0b943bac3834a4754"

  bottle do
    cellar :any_skip_relocation
    sha256 "a45ecb8df55622afe4755ca0faf16ffe8ecc5af9fc71bcf06038576623a94061" => :catalina
    sha256 "3ea483a54a5c9196ee7a96efea8e80b57208875818d5a83f78ea4d53fff52f8d" => :mojave
    sha256 "11fb69e1ffbe3b1dd7e4b6054cf9bdcaf6583b9183db51edb845fdd3bdc573db" => :high_sierra
    sha256 "d65bed84ea552fff46042ceb61936a79e02a6ffc1a93e4e09b3efff3aa6b7880" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "openssl@1.1"

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    system bin/"monolith", "https://lyrics.github.io/db/p/portishead/dummy/roads"
  end
end
