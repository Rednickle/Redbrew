require "language/haskell"

class DhallJson < Formula
  include Language::Haskell::Cabal

  desc "Dhall to JSON compiler and a Dhall to YAML compiler"
  homepage "https://github.com/dhall-lang/dhall-haskell/tree/master/dhall-json"
  url "https://hackage.haskell.org/package/dhall-json-1.6.3/dhall-json-1.6.3.tar.gz"
  sha256 "6b41f69f1c97515061b02fdbb82f867076d7ad1c345c1d1a6249348b6ca6a6b6"
  head "https://github.com/dhall-lang/dhall-haskell.git"

  bottle do
    sha256 "5babf84a94b0854aa9557c5febb4423fe953d62af688a9c5d392051fcbdb5499" => :catalina
    sha256 "5336561b5593fffbd178a63863bb8bdf35522053111cceb9466b406a3a4dbf61" => :mojave
    sha256 "ef0ddd01742ba97c829c81cdb784036bf8644cf78ac92de5b1b02baf1fdbb185" => :high_sierra
    sha256 "323d7f2b0f76ef77793ac943662cba5c982eccce6b743aa4805efe6982979be0" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc@8.6" => :build

  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  def install
    install_cabal_package
  end

  test do
    assert_match "1", pipe_output("#{bin}/dhall-to-json", "1", 0)
  end
end
