class Gowsdl < Formula
  desc "WSDL2Go code generation as well as its SOAP proxy"
  homepage "https://github.com/hooklift/gowsdl"
  url "https://github.com/hooklift/gowsdl/archive/v0.3.0.tar.gz"
  sha256 "24110596c7c658262ba83a4c0f7f568f3f17c4e657bc82a00c800507dfd65c5b"
  head "https://github.com/hooklift/gowsdl.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "60124759822dfa9cbb182818488f70f7dff36d68b1936b9a457844812f2034bf" => :mojave
    sha256 "631f836ce7d3f08f8becbd915ef2634b456e256c6cbb4f0450657cc6d1a13468" => :high_sierra
    sha256 "4395ff37e13fd146e3114beac5e8faa6a6a03819253760f5ef493c834374b905" => :sierra
    sha256 "98c739e6e8956da6cfbda48e973cceeb4add7d8c30e0cd79d66aebd0708f0efe" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    mkdir_p buildpath/"src/github.com/hooklift"
    ln_s buildpath, buildpath/"src/github.com/hooklift/gowsdl"

    ENV["GOPATH"] = buildpath

    system "make", "build"
    bin.install "build/gowsdl"
  end

  test do
    system "#{bin}/gowsdl"
  end
end
