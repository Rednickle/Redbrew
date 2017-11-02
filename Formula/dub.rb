class Dub < Formula
  desc "Build tool for D projects"
  homepage "https://code.dlang.org/getting_started"
  url "https://github.com/dlang/dub/archive/v1.6.0.tar.gz"
  sha256 "4b6a13232deeed60b262fcad95e8d45449e6407308f2962b08b3d9ecbcb80126"
  version_scheme 1

  head "https://github.com/dlang/dub.git"

  bottle do
    sha256 "02dca616f9005a97e8a808132e4db53a7b09a7c68b57ba1b7c617bf2548fe9af" => :high_sierra
    sha256 "93a16cf901414234c4345df869c818cadced49f50d15f54ee3e75100e5b16641" => :sierra
    sha256 "dfc6c60757b75435bb16018ae05e4ea8c3de8137922bfdc7043a33492a985a7e" => :el_capitan
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

  devel do
    url "https://github.com/dlang/dub/archive/v1.6.0-beta.2.tar.gz"
    sha256 "da1877c7c39a4905bca78083784733bfae59d60c7b665169d87fe2d81651b38f"
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
