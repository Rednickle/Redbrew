class Fwup < Formula
  desc "Configurable embedded Linux firmware update creator and runner"
  homepage "https://github.com/fhunleth/fwup"
  url "https://github.com/fhunleth/fwup/releases/download/v1.3.0/fwup-1.3.0.tar.gz"
  sha256 "aa273338c4b3813c7c9ffe2397a20ff88a882db2049be70c01fd3ed0657abef6"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "e4ed30081aece27325565f00be9fae461bbf50b9a9ab256d0265f72afb65265a" => :mojave
    sha256 "46e54bb9df5460b370d88cf4afb0f094b208e032b6de8a162f93696ff4e4bb9b" => :high_sierra
    sha256 "a2ee234f6351f7ce8f6028bb2ea67c00f58fe9bf055c23b0f1aee7ffd47f82f7" => :sierra
    sha256 "1f8616fbae4c1d2d0e5b5410d18c9d76823ece22c085bb6db8e4921b80080172" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "confuse"
  depends_on "libarchive"
  depends_on "libsodium"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    system bin/"fwup", "-g"
    assert_predicate testpath/"fwup-key.priv", :exist?, "Failed to create fwup-key.priv!"
    assert_predicate testpath/"fwup-key.pub", :exist?, "Failed to create fwup-key.pub!"
  end
end
