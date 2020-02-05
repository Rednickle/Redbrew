class Meilisearch < Formula
  desc "Ultra relevant, instant and typo-tolerant full-text search API"
  homepage "https://docs.meilisearch.com/"
  url "https://github.com/meilisearch/MeiliSearch/archive/v0.8.4.tar.gz"
  sha256 "a45e128248bc911e9c4358b44e8afc0e29bbb8dd7b79fd9384c11b8a215256e6"

  bottle do
    cellar :any_skip_relocation
    sha256 "4c0cf2771d4f20ac3d1e48e92c5d5e8e2ef9306b0d3689b45e87c2db064dfddd" => :catalina
    sha256 "dc832f214ea74897de8b6713bc6fa0e037209af0823770f3c6a7e5206c3394a4" => :mojave
    sha256 "f1e152cd4e0856051e2227ae869ff37b11181f645b5c544ffce00c035d8ce252" => :high_sierra
    sha256 "a41be5cf0e99e3e2b8f628791fe8d89c54395a439cc5c05a3a961729377f0feb" => :x86_64_linux
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "meilisearch-http"
  end

  test do
    output = shell_output("#{bin}/meilisearch --version")
    assert_match(/^meilisearch-http [0-9]*[.][0-9]*[.][0-9]*/, output)
  end
end
