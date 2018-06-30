class CIRequirement < Requirement
  fatal true
  satisfy { ENV["CIRCLECI"].nil? && ENV["TRAVIS"].nil? }
end

class CrystalLang < Formula
  desc "Fast and statically typed, compiled language with Ruby-like syntax"
  homepage "https://crystal-lang.org/"

  stable do
    url "https://github.com/crystal-lang/crystal/archive/0.25.1.tar.gz"
    sha256 "9b5a7bd2de67ab36cc5430133228a1e656a431fc7d928a37a61109bd8da77fc6"

    resource "shards" do
      url "https://github.com/crystal-lang/shards/archive/v0.8.1.tar.gz"
      sha256 "75c74ab6acf2d5c59f61a7efd3bbc3c4b1d65217f910340cb818ebf5233207a5"
    end
  end

  bottle do
    sha256 "91dec0830cbb6f707eaaf4fc75476d7d1a119bbaa72033b70209ed4cdd7e1e78" => :high_sierra
    sha256 "fde9cc0943039016a086859b34ba0ea2fa0ac76f484a1262461989f88aecf372" => :sierra
    sha256 "ce1829da7a8add5eb250a1dd37586f2ba46cf2bb218258f41e18351e1074a55d" => :el_capitan
  end

  head do
    url "https://github.com/crystal-lang/crystal.git"

    resource "shards" do
      url "https://github.com/crystal-lang/shards.git"
    end
  end

  option "without-release", "Do not build the compiler in release mode"
  option "without-shards", "Do not include `shards` dependency manager"

  depends_on "pkg-config" => :build
  depends_on "libatomic_ops" => :build # for building bdw-gc
  depends_on "libevent"
  depends_on "bdw-gc"
  depends_on "llvm@5"
  depends_on "pcre"
  depends_on "gmp" # std uses it but it's not linked
  depends_on "libyaml" if build.with? "shards"
  depends_on CIRequirement

  resource "boot" do
    if OS.mac?
      url "https://github.com/crystal-lang/crystal/releases/download/0.25.0/crystal-0.25.0-2-darwin-x86_64.tar.gz"
      version "0.25.0-2"
      sha256 "4f538660c097b7e6607df2953f34a6d6a1693e5a984cf4b1b1e77024029dc8fb"
    elsif MacOS.version <= :el_capitan # no clock_gettime
      url "https://github.com/crystal-lang/crystal/releases/download/v0.24.1/crystal-0.24.1-2-darwin-x86_64.tar.gz"
      version "0.24.1"
      sha256 "2be256462f4388cd3bb14b1378ef94d668ab9d870944454e828b4145155428a0"
    else
      url "https://github.com/crystal-lang/crystal/releases/download/0.25.0/crystal-0.25.0-1-linux-x86_64.tar.gz"
      version "0.25.0-1"
      sha256 "baa2081dbad6c8645dfa894e7249bb77ca80db7affcbc574857bad6b103000e0"
    end
  end

  def install
    (buildpath/"boot").install resource("boot")

    if build.head?
      ENV["CRYSTAL_CONFIG_VERSION"] = Utils.popen_read("git rev-parse --short HEAD").strip
    else
      ENV["CRYSTAL_CONFIG_VERSION"] = version
    end

    ENV["CRYSTAL_CONFIG_PATH"] = prefix/"src:lib"
    ENV.append_path "PATH", "boot/bin"

    system "make", "deps"
    (buildpath/".build").mkpath

    command = ["bin/crystal", "build", "-D", "without_openssl", "-D", "without_zlib", "-o", ".build/crystal", "src/compiler/crystal.cr"]
    command.concat ["--release", "--no-debug"] if build.with? "release"

    system *command

    if build.with? "shards"
      resource("shards").stage do
        system buildpath/"bin/crystal", "build", "-o", buildpath/".build/shards", "src/shards.cr"
      end
      bin.install ".build/shards"
    end

    bin.install ".build/crystal"
    prefix.install "src"
    bash_completion.install "etc/completion.bash" => "crystal"
    zsh_completion.install "etc/completion.zsh" => "_crystal"
  end

  test do
    assert_match "1", shell_output("#{bin}/crystal eval puts 1")
  end
end
