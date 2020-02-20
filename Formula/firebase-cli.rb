require "language/node"

class FirebaseCli < Formula
  desc "Firebase command-line tools"
  homepage "https://firebase.google.com/docs/cli/"
  url "https://registry.npmjs.org/firebase-tools/-/firebase-tools-7.13.1.tgz"
  sha256 "3900f085296e0c3645980b4326f5f340712f7d99fdaa1991a1bc62f3351f33d0"
  head "https://github.com/firebase/firebase-tools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "55ab12705a840bd59c05c069bcf81a15c91d8aebfba4d4f6613b6f0e3fecd861" => :catalina
    sha256 "65d9baced9af305c2054f35425df6d9b1bfbc910967597662e26f39a7e821d3b" => :mojave
    sha256 "8c1656b0930ed50c5dfa17f7f0bfb999341e17ae2787640fd683a01463518729" => :high_sierra
    sha256 "7267961ae5a0e4cce3586dca56941c07dded0c4e6c6a6e6c8cb62cb6e753b9b2" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    # The following test requires /usr/bin/expect.
    return unless OS.mac?

    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/firebase login:ci --no-localhost
      expect "Paste"
    EOS
    assert_match "authorization code", shell_output("expect -f test.exp")
  end
end
