class CabalInstall < Formula
  desc "Command-line interface for Cabal and Hackage"
  homepage "https://www.haskell.org/cabal/"
  url "https://hackage.haskell.org/package/cabal-install-2.0.0.1/cabal-install-2.0.0.1.tar.gz"
  sha256 "f991e36f3adaa1c7e2f0c422a2f2a4ab21b7041c82a8896f72afc9843a0d5d99"
  head "https://github.com/haskell/cabal.git", :branch => "2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "03f2436d90d102a0b213ff852bfda988853faee571fc50d91831a3feefc7e671" => :high_sierra
    sha256 "2ad3ac7ef020067a14e988d74823018b2be633d7af53d5af435ae1fa795dbd0d" => :sierra
    sha256 "1d194910abf09edaa50a09c8c1732f2801ed7efd21b06cb982c0d90a990d5b56" => :el_capitan
    sha256 "e7027a7d4fe9712d4fff6ba3bf02d187ed74026886142ee5e6adbf29f2b5c281" => :x86_64_linux
  end

  depends_on "ghc@8.2"
  depends_on "zlib" unless OS.mac?

  fails_with :clang if MacOS.version <= :lion # Same as ghc.rb

  def install
    cd "cabal-install" if build.head?

    system "sh", "bootstrap.sh", "--sandbox"
    bin.install ".cabal-sandbox/bin/cabal"
    bash_completion.install "bash-completion/cabal"
  end

  test do
    ENV.prepend_path "PATH", Formula["ghc@8.2"].opt_bin
    system "#{bin}/cabal", "--config-file=#{testpath}/config", "info", "cabal"
  end
end
