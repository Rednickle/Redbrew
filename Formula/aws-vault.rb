class AwsVault < Formula
  desc "Securely store and access AWS credentials in development environments"
  homepage "https://github.com/99designs/aws-vault"
  url "https://github.com/99designs/aws-vault/archive/v5.3.0.tar.gz"
  sha256 "b573da516e1e2fe913f8d0f135e5aba1707ebea2f1aacf16f2c46f60dc0cc927"

  bottle do
    cellar :any_skip_relocation
    sha256 "000b93b5119c965bcee1f19c28a82bbf580840aeb288232c46390fd2ccac60c4" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on :linux

  def install
    ENV["GOOS"] = "linux"
    ENV["GOARCH"] = "amd64"

    flags = "-X main.Version=#{version} -s -w"

    system "go", "build", "-ldflags=#{flags}"
    bin.install "aws-vault"

    zsh_completion.install "completions/zsh/_aws-vault"
    bash_completion.install "completions/bash/aws-vault"
  end

  test do
    assert_match("aws-vault: error: required argument 'profile' not provided, try --help", shell_output("#{bin}/aws-vault login 2>&1", 1))
  end
end
