class Lazygit < Formula
  desc "Simple terminal UI for git commands"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/jesseduffield/lazygit/archive/v0.16.tar.gz"
  sha256 "51593353676c64de955775128e29d74365cdea4a9e946999fe6be8fb0b4c4268"

  bottle do
    cellar :any_skip_relocation
    sha256 "cdee3efe9c8d688a14db5cf003437d93d587fdd80710b93611178b93a91918f7" => :catalina
    sha256 "98ef900b7ad966bda2cca2192195c82b917ee10456f4d967ed74930c9f874630" => :mojave
    sha256 "fb52918313e72134c842e146be762004b63c68ca46d23609fa50895d186c71a1" => :high_sierra
    sha256 "ee11f10f93a3bc00da997318c74e52bbad37ebfe6ac7d454c3dc517d71b8d8c7" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-mod=vendor", "-o", bin/"lazygit",
      "-ldflags", "-X main.version=#{version} -X main.buildSource=homebrew"
  end

  # lazygit is a terminal GUI, but it can be run in 'client mode' for example to write to git's todo file
  test do
    (testpath/"git-rebase-todo").write ""
    ENV["LAZYGIT_CLIENT_COMMAND"] = "INTERACTIVE_REBASE"
    ENV["LAZYGIT_REBASE_TODO"] = "foo"
    system "#{bin}/lazygit", "git-rebase-todo"
    assert_match "foo", (testpath/"git-rebase-todo").read
  end
end
