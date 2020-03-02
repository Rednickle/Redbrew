class StressNg < Formula
  desc "Stress test a computer system in various selectable ways"
  homepage "https://kernel.ubuntu.com/~cking/stress-ng/"
  url "https://kernel.ubuntu.com/~cking/tarballs/stress-ng/stress-ng-0.11.01.tar.xz"
  sha256 "9fe19548c87aa1a1b9b2be3b359ec2621b88bcb16998b77527549a7736f65494"

  bottle do
    cellar :any_skip_relocation
    sha256 "59b20d718ae94d3ffed7b7157eb19c8e413fa9d4d85a30ad262041312768b8dd" => :catalina
    sha256 "93f1d44ee52270ceac7e3f326b8d2d5552405eb52517eaeee49a3e8f9d5281f9" => :mojave
    sha256 "e88b1bdf6c7bd4016adf2a1da6777889b0a92fd5c44eb2814977e9d7895f8894" => :high_sierra
    sha256 "361fc53b3461a6bbb14e245d41db6f66f8b918773bfe176dc04d93d04d9b04b7" => :x86_64_linux
  end

  depends_on :macos => :sierra if OS.mac?

  uses_from_macos "zlib"

  def install
    inreplace "Makefile", "/usr", prefix
    system "make"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/stress-ng -c 1 -t 1 2>&1")
    assert_match "successful run completed", output
  end
end
