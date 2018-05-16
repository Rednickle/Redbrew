class YouGet < Formula
  include Language::Python::Virtualenv

  desc "Dumb downloader that scrapes the web"
  homepage "https://you-get.org/"
  url "https://github.com/soimort/you-get/releases/download/v0.4.1077/you-get-0.4.1077.tar.gz"
  sha256 "2a4c197c70a442e75b894f10ea78c35c16e11029e8f685811aa3e4f57eb0c4e1"
  head "https://github.com/soimort/you-get.git", :branch => "develop"

  bottle do
    cellar :any_skip_relocation
    sha256 "7b0d69ef147e6cd2ff8ab3ef5b0ac99181aa4c7b6573e11bd05630e3679f1817" => :x86_64_linux
  end

  depends_on "python"

  depends_on "rtmpdump" => :optional

  def install
    virtualenv_install_with_resources
  end

  def caveats
    "To use post-processing options, `brew install ffmpeg` or `brew install libav`."
  end

  test do
    system bin/"you-get", "--info", "https://youtu.be/he2a4xK8ctk"
  end
end
