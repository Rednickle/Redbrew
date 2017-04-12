class Heroku < Formula
  desc "Everything you need to get started with Heroku"
  homepage "https://cli.heroku.com"
  if OS.mac?
    url "https://cli-assets.heroku.com/branches/stable/5.8.5-614a805/heroku-v5.8.5-614a805-darwin-amd64.tar.xz"
    sha256 "9f108c351f887866d9887169069740648006459575e4064e7c810c46da27cb0b"
  elsif OS.linux?
    url "https://cli-assets.heroku.com/branches/stable/5.8.5-614a805/heroku-v5.8.5-614a805-linux-amd64.tar.xz"
    sha256 "7df5335ff817e134d53eeb93f2240b79b73abf29cea465fe8d6438bc518da856"
  end
  version "5.8.5"

  bottle :unneeded

  depends_on :arch => :x86_64

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/heroku"
  end

  test do
    system bin/"heroku", "version"
  end
end

