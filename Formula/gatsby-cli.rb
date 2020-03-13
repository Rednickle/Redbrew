require "language/node"

class GatsbyCli < Formula
  desc "Gatsby command-line interface"
  homepage "https://www.gatsbyjs.org/docs/gatsby-cli/"
  url "https://registry.npmjs.org/gatsby-cli/-/gatsby-cli-2.10.9.tgz"
  sha256 "f8f09e9b9b188709c89305f1dd99d9bb1a52664c20321bbd6e3b96ee03a23332"

  bottle do
    cellar :any_skip_relocation
    sha256 "2fba761f3f44d39da950f8fae9c5936491806eabf4acf6fc863037370239c665" => :catalina
    sha256 "e4ba2a6e5764dae69b5ccd08d5c9a16289f0ef2b89c4d2bfa9a000b28c81bbec" => :mojave
    sha256 "7d84ad9e8c130888fe546f8710fd655f30271e2d00af6f5c274220c595ac2f68" => :high_sierra
    sha256 "29c2bd33e7cd79f6b01a5cb39d799c003cad9153eb0db5c8c8d8ae0f798b2863" => :x86_64_linux
  end

  depends_on "node"
  depends_on "linuxbrew/xorg/xorg" unless OS.mac?

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    return if Process.uid.zero?

    system bin/"gatsby", "new", "hello-world", "https://github.com/gatsbyjs/gatsby-starter-hello-world"
    assert_predicate testpath/"hello-world/package.json", :exist?, "package.json was not cloned"
  end
end
