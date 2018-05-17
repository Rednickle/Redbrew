class ForkCleaner < Formula
  desc "Cleans up old and inactive forks on your GitHub account"
  homepage "https://github.com/caarlos0/fork-cleaner"
  url "https://github.com/caarlos0/fork-cleaner/archive/v1.3.1.tar.gz"
  sha256 "d3259e74eb12f588fbd3073a27ba6efd4d36e467e84d346a466815fa8a4920ae"

  bottle do
    cellar :any_skip_relocation
    sha256 "bd4e200d3acca2ef2017d00940ccc4d0fc65f5383ff1738cb15b16cada46bd57" => :x86_64_linux
  end

  depends_on "dep" => :build
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/caarlos0/fork-cleaner"
    dir.install buildpath.children
    cd dir do
      system "dep", "ensure"
      system "make"
      bin.install "fork-cleaner"
      prefix.install_metafiles
    end
  end

  test do
    output = shell_output("#{bin}/fork-cleaner 2>&1", 1)
    assert_match "missing github token", output
  end
end
