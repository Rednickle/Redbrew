class Ghq < Formula
  desc "Remote repository management made easy"
  homepage "https://github.com/motemen/ghq"
  url "https://github.com/motemen/ghq.git",
      :tag      => "v0.12.8",
      :revision => "fe5ca0511e4d028be926215d05590638e3995c99"
  head "https://github.com/motemen/ghq.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c17b2fd413cb7a1a2c681e863fc3ea5ff14b3910bf77b37464812fca3b0875b5" => :catalina
    sha256 "9e421aaaf0c7b2340c7367d70144a7f1b8a99f37f3165abcd8527afd6e1989a1" => :mojave
    sha256 "441bec0507a8ec029a4afa8832e7d64a26775d50859226859b1098f912f32918" => :high_sierra
  end

  depends_on "go" => :build

  # Go 1.13 compatibility, remove when version > 0.12.6
  patch do
    url "https://github.com/motemen/ghq/pull/193.patch?full_index=1"
    sha256 "03e9a4297d8ab94355f1f7fda2880e555154d034f3a670910fb0574b463f6468"
  end

  def install
    system "make", "build"
    bin.install "ghq"
    zsh_completion.install "zsh/_ghq"
    prefix.install_metafiles
  end

  test do
    assert_match "#{testpath}/.ghq", shell_output("#{bin}/ghq root")
  end
end
