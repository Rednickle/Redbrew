class Packmol < Formula
  desc "Packing optimization for molecular dynamics simulations"
  homepage "https://www.ime.unicamp.br/~martinez/packmol/"
  url "https://github.com/leandromartinez98/packmol/archive/17.221.tar.gz"
  sha256 "b5dcdeb694ffc17f620a4517e4eba67018145774d6fa06c4076bfbfe79400407"
  head "https://github.com/leandromartinez98/packmol.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    prefix "/home/linuxbrew/.linuxbrew"
    cellar :any_skip_relocation
    sha256 "94c754110714ab922137e7b2dc01e2ba580795364b9200954520dc77b2302022" => :high_sierra
    sha256 "b08cdbaf8889812816c9a3999304fef09edbb4ebee08932d5aad2a3b09b2377b" => :sierra
    sha256 "551f3a99d27dcc0d4c1a4c56526d22e2bcea25a8dc1551da62b806bc6760c3d4" => :el_capitan
    sha256 "cf3c0f1d3cc39e1832432db174acb4f06ad53b460a927b76b63c97b6cba0baad" => :yosemite
    sha256 "6668bde18b3bb98332f2d6fa3ad5cbab1128983aabbbbd0caa6168bc6f1dd5a3" => :x86_64_linux # glibc 2.19
  end

  depends_on :fortran

  resource "examples" do
    url "https://www.ime.unicamp.br/~martinez/packmol/examples/examples.tar.gz"
    sha256 "97ae64bf5833827320a8ab4ac39ce56138889f320c7782a64cd00cdfea1cf422"
  end

  def install
    system "./configure"
    system "make"
    bin.install("packmol")
    pkgshare.install "solvate.tcl"
    (pkgshare/"examples").install resource("examples")
  end

  test do
    cp Dir["#{pkgshare}/examples/*"], testpath
    system bin/"packmol < interface.inp"
  end
end
