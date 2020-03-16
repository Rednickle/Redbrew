class Gitversion < Formula
  desc "Easy semantic versioning for projects using Git"
  homepage "https://github.com/GitTools/GitVersion"
  if OS.mac?
    url "https://github.com/GitTools/GitVersion/releases/download/5.2.0/gitversion-osx-5.2.0.tar.gz"
    sha256 "5fa276054e46c21a0b0cc052ded2fc1a598979a887e6b21d17000d0915c42462"
  else
    url "https://github.com/GitTools/GitVersion/releases/download/5.2.0/gitversion-linux-5.2.0.tar.gz"
    sha256 "8dad2624bdf2be5330ae37ead9aca912322d02e49a82df17c29906a779ba6e93"
  end

  bottle :unneeded

  uses_from_macos "icu4c"

  def install
    libexec.install Dir["*"]
    (bin/"gitversion").write <<~EOS
      #!/bin/sh
      #{OS.mac? ? "" : "export LD_LIBRARY_PATH=#{HOMEBREW_PREFIX}/lib"}
      exec "#{libexec}/GitVersion" "$@"
    EOS
  end

  test do
    # Circumvent GitVersion's build server detection scheme:
    ENV["JENKINS_URL"] = nil

    (testpath/"test.txt").write("test")
    system "git", "init"
    system "git", "add", "test.txt"
    unless OS.mac?
      system "git", "config", "user.email", "you@example.com"
      system "git", "config", "user.name", "Your Name"
    end
    system "git", "commit", "-q", "--author='Test <test@example.com>'", "--message='Test'"
    assert_match '"FullSemVer":"0.1.0+0"', shell_output("#{bin}/gitversion -output json")
  end
end
