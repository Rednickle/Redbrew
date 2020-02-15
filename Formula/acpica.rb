class Acpica < Formula
  desc "OS-independent implementation of the ACPI specification"
  homepage "https://www.acpica.org/"
  url "https://acpica.org/sites/acpica/files/acpica-unix-20200214.tar.gz"
  sha256 "e77ab9f8557ca104f6e8f49efaa8eead29f78ca11cadfc8989012469ecc0738e"
  head "https://github.com/acpica/acpica.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c951b6313c4c88a6a0f4cff7d8e9f832f2301f87dbe03590fa18872c57933aaf" => :catalina
    sha256 "77737d68f935fbc09f9a27805c3c86a0dc9c812378cdc512a3385951249347c3" => :mojave
    sha256 "19bde18f6e8eb1616c8ed61b6d12a813252463e1cecfd6b3a22e3c28c895020e" => :high_sierra
    sha256 "c39200d0507c0eb0ff34509e6bb25c3605a6e46037f3b9cc5656e38ca27294bc" => :x86_64_linux
  end

  unless OS.mac?
    depends_on "bison" => :build
    depends_on "flex" => :build
    depends_on "m4" => :build
  end

  def install
    ENV.deparallelize
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/acpihelp", "-u"
  end
end
