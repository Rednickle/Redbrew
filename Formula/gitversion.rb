class Gitversion < Formula
  desc "Easy semantic versioning for projects using Git"
  homepage "https://github.com/GitTools/GitVersion"
  if OS.mac?
    url "https://github.com/GitTools/GitVersion/releases/download/5.2.4/gitversion-osx-5.2.4.tar.gz"
    sha256 "a06ae6cf8062a2b26b858feab01fceb94951627cc732f7422472785ff3ccde4c"
  else
    url "https://github.com/GitTools/GitVersion/releases/download/5.2.4/gitversion-linux-5.2.4.tar.gz"
    sha256 "d406fa3b1e289c0621ae70408a6254b6eeac9d1658c85cef6f1704da9a544c0c"
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
