class AwsVault < Formula
  desc "Securely store and access AWS credentials in development environments"
  homepage "https://github.com/99designs/aws-vault"
  url "https://github.com/99designs/aws-vault/archive/v5.3.2.tar.gz"
  sha256 "6bca7d1bebf02e72714bfbfa162cbb38a33a48e4ea64dc2829626ff68a407a6a"

  bottle do
    cellar :any_skip_relocation
    sha256 "ee4c305741bcf6191f3e7083fd544d5c99887c07bb4998e90057f8a03d9465ff" => :x86_64_linux
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
    assert_match("aws-vault: error: required argument 'profile' not provided, try --help",
      shell_output("#{bin}/aws-vault login 2>&1", 1))
  end
end
