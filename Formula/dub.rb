class Dub < Formula
  desc "Build tool for D projects"
  homepage "https://code.dlang.org/getting_started"
  url "https://github.com/dlang/dub/archive/v1.5.0.tar.gz"
  sha256 "3509f959cc5b34e44adaae586b62ded387ac10031f6c1aaf1cfbb4aae5af37dd"
  version_scheme 1

  head "https://github.com/dlang/dub.git"

  bottle do
    sha256 "2fa310eadd78afbe3e9fa2bf6129075d1e8ebc0cfbcbc85790576bcf887194da" => :sierra
    sha256 "14408bc3f1ed7c5193c37bd61f570ad22f8920d6b00cce1613a582bbbced8312" => :el_capitan
    sha256 "672931bef778a726c69692c0ca4cb3145ef5ba55cd616865dccc4e818ea0079d" => :yosemite
    sha256 "8e357f02fef14be2775e6e3bd33b3ce922811c97642d1057f4ca6ad1b8800ced" => :x86_64_linux
  end

  devel do
    url "https://github.com/dlang/dub/archive/v1.5.0-beta.1.tar.gz"
    sha256 "fd95787065f1059e8c29801e3f8bef3661fa37ed8bf39e2f379280e52433e37e"

    # Minor problem with a missing public import, fixed in master,
    # fix should be in next beta
    patch do
      url "https://github.com/dlang/dub/pull/1221.patch?full_index=1"
      sha256 "40b38363c91f6aa1440d81f2b3cb29f0bf8aab3b8e945503437f271d290f4344"
    end
  end

  depends_on "pkg-config" => [:recommended, :run]
  depends_on "dmd" => :build
  depends_on "curl" unless OS.mac?

  def install
    ENV["GITVER"] = version.to_s
    system "./build.sh"
    bin.install "bin/dub"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dub --version").split(/[ ,]/)[2]
  end
end
