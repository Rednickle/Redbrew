class LaszipAT2 < Formula
  desc "Lossless LiDAR compression"
  homepage "https://www.laszip.org/"
  url "https://github.com/LASzip/LASzip/archive/v2.2.0.tar.gz"
  sha256 "b8e8cc295f764b9d402bc587f3aac67c83ed8b39f1cb686b07c168579c61fbb2"

  bottle do
    cellar :any_skip_relocation
    sha256 "1552904730867b91d1c33d5d11ec29ba285f7dc164a17805e02555d16e4bf501" => :high_sierra
    sha256 "c8c8f7ec659721bdc5a44c78d521517a99bc083f3a7e6406cd0b9060c09de09f" => :sierra
    sha256 "4d2f138afacf7750ddb56c4cfbd09590b38c63c5fae9765045192565e7508465" => :el_capitan
    sha256 "14ef1745b0765281286006b83de845babd661df6cd0c29c37e108f036d2a6a3b" => :x86_64_linux
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "#{bin}/laszippertest"
  end
end
