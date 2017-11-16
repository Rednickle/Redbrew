class AppEngineGo64 < Formula
  desc "Google App Engine SDK for Go (AMD64)"
  homepage "https://cloud.google.com/appengine/docs/go/"
  if OS.mac?
    url "https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_darwin_amd64-1.9.61.zip"
    sha256 "4291ecc6939e557d73c44fe742dba4c5f42d3455e56480f96ee86b6ba34c99e3"
  elsif OS.linux?
    url "https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_linux_amd64-1.9.60.zip"
    sha256 "e59217e0c25f8beb77ad5d765e265463b502219c38fd70a16af355533a894c7d"
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
