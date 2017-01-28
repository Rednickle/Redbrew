class AndroidPlatformTools < Formula
  desc "Tools for the Android SDK"
  homepage "https://developer.android.com/studio/releases/platform-tools.html"
  # the url is from:
  # https://dl.google.com/android/repository/repository-12.xml
  version "25.0.3"
  url "https://dl.google.com/android/repository/platform-tools_r#{version}-#{OS::NAME}.zip"
  if OS.mac?
    sha256 "640ce3236ba5eddc91bcd098b7e0c051b7ee3860339a14a4fe2d3caf7f6729cf"
  elsif OS.linux?
    sha256 "0e14aeb696df691dead0dfd9e25249efaea3bfa548f782d9f7edd13a7bdcbe3f"
  end

  bottle :unneeded

  depends_on :macos => :mountain_lion

  conflicts_with "android-sdk",
    :because => "the Android Platform-tools are part of the Android SDK"

  def install
    bin.install "adb", "fastboot"
  end

  test do
    system bin/"fastboot --version"
    system bin/"adb version"
  end
end
