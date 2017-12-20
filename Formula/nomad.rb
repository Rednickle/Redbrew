class Nomad < Formula
  desc "Distributed, Highly Available, Datacenter-Aware Scheduler"
  homepage "https://www.nomadproject.io"
  url "https://github.com/hashicorp/nomad/archive/v0.7.1.tar.gz"
  sha256 "312b7d89b0d03154b9c84672f013ff0d9c44dda0a73a8187d5509088fe0051c0"
  head "https://github.com/hashicorp/nomad.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "650feea1f9bf5813aea5390d0eb0a6c6b8491ecff46be090774bd27b5cba49e9" => :high_sierra
    sha256 "e0e420c63315e67b6e7aa4ee6b32380ef7b4a95113d6c8ab6c0131393056e3a7" => :sierra
    sha256 "0a1d0ab2283e6b93de5e576b9c88e4ed230a31317138c88df0d2011a62a3ef0a" => :el_capitan
    sha256 "72dd0a46e4bd55b95bdecfa7b9c98719f55a2def518614d60f9b61289c9ccbd1" => :x86_64_linux
  end

  option "with-dynamic", "Build dynamic binary with CGO_ENABLED=1"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/hashicorp/nomad").install buildpath.children
    cd "src/github.com/hashicorp/nomad" do
      ENV["CGO_ENABLED"] = "1" if build.with? "dynamic"
      system "go", "build", "-o", bin/"nomad"
      prefix.install_metafiles
    end
  end

  test do
    begin
      pid = fork do
        exec "#{bin}/nomad", "agent", "-dev"
      end
      sleep 10
      ENV.append "NOMAD_ADDR", "http://127.0.0.1:4646"
      system "#{bin}/nomad", "node-status"
    ensure
      Process.kill("TERM", pid)
    end
  end
end
