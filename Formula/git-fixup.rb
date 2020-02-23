class GitFixup < Formula
  desc "Alias for git commit --fixup <ref>"
  homepage "https://github.com/keis/git-fixup"
  url "https://github.com/keis/git-fixup/archive/v1.3.0.tar.gz"
  sha256 "29665151f82cac5f5807b8241392150e7c8ee8024ce37f23752c23c134516d57"
  head "https://github.com/keis/git-fixup.git", :branch => "master"

  bottle do
    cellar :any_skip_relocation
    sha256 "adb91d6c86a8330a51394a03e20b5d7dc20144ee80426802b1b651766fc2462e" => :catalina
    sha256 "adb91d6c86a8330a51394a03e20b5d7dc20144ee80426802b1b651766fc2462e" => :mojave
    sha256 "adb91d6c86a8330a51394a03e20b5d7dc20144ee80426802b1b651766fc2462e" => :high_sierra
    sha256 "cc910330abea2784fa0ef9383bc3c76e96e94364727798b7bc34694ce74184b2" => :x86_64_linux
  end

  def install
    system "make", "PREFIX=#{prefix}", "install"
    zsh_completion.install "completion.zsh" => "_git-fixup"
  end

  test do
    (testpath/".gitconfig").write <<~EOS
      [user]
        name = Real Person
        email = notacat@hotmail.cat
    EOS
    system "git", "init"
    (testpath/"test").write "foo"
    system "git", "add", "test"
    system "git", "commit", "--message", "Initial commit"

    (testpath/"test").delete
    (testpath/"test").write "bar"
    system "git", "add", "test"
    system "git", "fixup"
  end
end
