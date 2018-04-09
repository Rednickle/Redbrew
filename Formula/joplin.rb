require "language/node"

class Joplin < Formula
  desc "Note taking and to-do application with synchronisation capabilities"
  homepage "https://joplin.cozic.net/"
  url "https://registry.npmjs.org/joplin/-/joplin-1.0.106.tgz"
  sha256 "c1f1b19f0d078cd232bce5f62e8ec4f1a69bfcddf1cb90701c7cd7a4ecc59613"

  bottle do
    sha256 "e6a2d46d4a252486272556c71f3b39250406556924eeddbea732aa794a27b700" => :high_sierra
    sha256 "1601f5efb1b92c1006b3832a17dcd6a844546e86a150d6c54e7effde9fe83439" => :sierra
    sha256 "39314499551b6fb63782bc70c5bc669392688cbe1affabbf3090b04569b8b08b" => :el_capitan
    sha256 "712239d0360769452c66e6d5914cb0766d0cb26cc6847b7003a19d22688cd56c" => :x86_64_linux
  end

  depends_on "node"
  depends_on "python@2" => :build

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"joplin", "config", "editor", "subl"
    assert_match "editor = subl", shell_output("#{bin}/joplin config")
  end
end
