require "language/node"

class FirebaseCli < Formula
  desc "Firebase command-line tools"
  homepage "https://firebase.google.com/docs/cli/"
  url "https://registry.npmjs.org/firebase-tools/-/firebase-tools-7.14.0.tgz"
  sha256 "28dfb68a9e8894aa7c6fded7faebf2a375b49aebce44603250f08232a1cc6118"
  head "https://github.com/firebase/firebase-tools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "ae1639171a855848b00f468dd6365496cc41be428ca8b8f329bc89cfbd58a065" => :catalina
    sha256 "d8123b07ed0d2494685fc1e22d40076c407cc13591b0d5540748121265ec95f5" => :mojave
    sha256 "871e0d20a401eed7a2c3589353d125a58347052490e632ab5769308bd5095873" => :high_sierra
    sha256 "27c547dd795a8067577330ece779aef1bc5d0ec2a62f2fb596aa946b2ac9445c" => :x86_64_linux
  end

  depends_on "node"

  uses_from_macos "expect" => :test

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/firebase login:ci --no-localhost
      expect "Paste"
    EOS
    assert_match "authorization code", shell_output("expect -f test.exp")
  end
end
