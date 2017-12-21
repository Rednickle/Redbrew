class StressNg < Formula
  desc "Stress test a computer system in various selectable ways"
  homepage "http://kernel.ubuntu.com/~cking/stress-ng/"
  url "http://kernel.ubuntu.com/~cking/tarballs/stress-ng/stress-ng-0.09.06.tar.xz"
  sha256 "59c09c7cccb34222dc124ce8622a0ac73fe9391ba16a4a561267ca55c02f2520"

  bottle do
    cellar :any_skip_relocation
    sha256 "d12df90843e3e9280cea73363a34e2d1aa05e068cacaf6468b16496678509646" => :high_sierra
    sha256 "db2810739690804afa23f0df40233271352a792ffbdf0e4ead7f9be8ed636bf2" => :sierra
    sha256 "ff233339fca651a41037730644e1540d23b3e38bc1bfe63db56a3f7a3172b8f9" => :x86_64_linux
  end

  depends_on :macos => :sierra

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
