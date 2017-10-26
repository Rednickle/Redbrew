class AppEngineGo64 < Formula
  desc "Google App Engine SDK for Go (AMD64)"
  homepage "https://cloud.google.com/appengine/docs/go/"
  if OS.mac?
    url "https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_darwin_amd64-1.9.60.zip"
    sha256 "b8b3e06629fc373619a23e427f43922eb39f87e07a75358925b259eed2f5c956"
  elsif OS.linux?
    url "https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_linux_amd64-1.9.60.zip"
    sha256 "ba384585c877371a445df24cb3fb89981e3df38e31f9d3f038714f4fc619622d"
  end

  bottle :unneeded

  conflicts_with "app-engine-go-32",
    :because => "both install the same binaries"
  conflicts_with "app-engine-python",
    :because => "both install the same binaries"

  def install
    pkgshare.install Dir["*"]
    %w[
      api_server.py appcfg.py bulkloader.py bulkload_client.py dev_appserver.py download_appstats.py goapp
    ].each do |fn|
      bin.install_symlink pkgshare/fn
    end
    (pkgshare/"goroot/pkg").install_symlink pkgshare/"goroot/pkg/darwin_amd64_appengine" => "darwin_amd64"
  end

  test do
    assert_match(/^usage: goapp serve/, shell_output("#{bin}/goapp help serve").strip)
  end
end
