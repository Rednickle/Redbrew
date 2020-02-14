class Istioctl < Formula
  desc "Istio configuration command-line utility"
  homepage "https://github.com/istio/istio"
  url "https://github.com/istio/istio.git",
      :tag      => "1.4.4",
      :revision => "30c10500ee49689826b87db65db133cbc4a7f52a"

  bottle do
    cellar :any_skip_relocation
    sha256 "dcdb7cd7cf4906be4a43271ac6e5f339f633fa48fe38c7f61a054df22205bbd0" => :catalina
    sha256 "dcdb7cd7cf4906be4a43271ac6e5f339f633fa48fe38c7f61a054df22205bbd0" => :mojave
    sha256 "dcdb7cd7cf4906be4a43271ac6e5f339f633fa48fe38c7f61a054df22205bbd0" => :high_sierra
    sha256 "daa991f79147a7a398c1b6254849632672fe9f9dae1118bade8eb988c1aa063b" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["TAG"] = version.to_s
    ENV["ISTIO_VERSION"] = version.to_s
    ENV["HUB"] = "docker.io/istio"

    srcpath = buildpath/"src/istio.io/istio"
    if OS.mac?
      outpath = buildpath/"out/darwin_amd64/release"
    else
      outpath = buildpath/"out/linux_amd64/release"
    end
    srcpath.install buildpath.children

    cd srcpath do
      system "make", "istioctl"
      prefix.install_metafiles
      bin.install outpath/"istioctl"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/istioctl version --remote=false")
  end
end
