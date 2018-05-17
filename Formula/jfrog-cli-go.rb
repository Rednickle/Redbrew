class JfrogCliGo < Formula
  desc "Command-line interface for Jfrog Artifactory and Bintray"
  homepage "https://github.com/JFrogDev/jfrog-cli-go"
  url "https://github.com/JFrogDev/jfrog-cli-go/archive/1.16.0.tar.gz"
  sha256 "0a6d6e1ddf015782e6545b4f5d5b440ca7a4ab4e56baac66fdd9258ba9ea74dc"

  bottle do
    cellar :any_skip_relocation
    sha256 "f5c7a0448b2410ece6d151b71e214bd8531701dd1c2a4d43aa5b69d45092c603" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/jfrogdev/jfrog-cli-go").install Dir["*"]
    cd "src/github.com/jfrogdev/jfrog-cli-go" do
      system "go", "build", "-o", bin/"jfrog", "jfrog-cli/jfrog/main.go"
      prefix.install_metafiles
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jfrog -v")
  end
end
