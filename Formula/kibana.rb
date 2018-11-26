class Kibana < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  url "https://github.com/elastic/kibana.git",
      :tag      => "v6.5.0",
      :revision => "467f35fbf730033dd5c3d1035512c16023551e87"
  head "https://github.com/elastic/kibana.git"

  bottle do
    sha256 "5096ccbcd409d29e0175f952bd93aea4fde4a3d33b162989205a81eed4373c6b" => :mojave
    sha256 "33c3ffe12c634984f506898ee753602b6a893bf2b255500e0f1995f4a17e7c73" => :high_sierra
    sha256 "204332a09a1e7e6e1cdc71f0cdf699ad060101739fd6cf1dd55a1e0bf6a04a37" => :sierra
  end

  resource "node" do
    url "https://nodejs.org/dist/v8.11.4/node-v8.11.4.tar.xz"
    sha256 "fbce7de6d96b0bcb0db0bf77f0e6ea999b6755e6930568aedaab06847552a609"

    # Fix compilation with gcc 5.4-5.5
    # https://github.com/Linuxbrew/homebrew-core/issues/9530
    # https://github.com/nodejs/node/pull/19196
    # Remove this patch after updating Node JS to >= v8.12
    patch :DATA unless OS.mac?
  end

  resource "yarn" do
    url "https://yarnpkg.com/downloads/1.12.3/yarn-v1.12.3.tar.gz"
    sha256 "02cd4b589ec22c4bdbd2bc5ebbfd99c5e99b07242ad68a539cb37896b93a24f2"
  end

  unless OS.mac?
    depends_on "python@2" => :build
    depends_on "linuxbrew/xorg/libx11"
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    resource("node").stage do
      system "./configure", "--prefix=#{libexec}/node"
      system "make", "install"
    end

    # remove non open source files
    rm_rf "x-pack"

    # patch build to not try to read tsconfig.json's from the removed x-pack folder
    inreplace "src/dev/typescript/projects.ts" do |s|
      s.gsub! "new Project(resolve(REPO_ROOT, 'x-pack/tsconfig.json')),", ""
      s.gsub! "new Project(resolve(REPO_ROOT, 'x-pack/test/tsconfig.json'), 'x-pack/test'),", ""
    end

    # trick the build into thinking we've already downloaded the Node.js binary
    mkdir_p buildpath/".node_binaries/#{resource("node").version}/darwin-x64"

    # run yarn against the bundled node version and not our node formula
    (buildpath/"yarn").install resource("yarn")
    (buildpath/".brew_home/.yarnrc").write "build-from-source true\n"
    ENV.prepend_path "PATH", buildpath/"yarn/bin"
    ENV.prepend_path "PATH", prefix/"libexec/node/bin"
    system "yarn", "kbn", "bootstrap"
    system "yarn", "build", "--oss", "--release", "--skip-os-packages", "--skip-archives"

    prefix.install Dir["build/oss/kibana-#{version}-darwin-x86_64/{bin,config,node_modules,optimize,package.json,src,ui_framework,webpackShims}"]
    mv "licenses/APACHE-LICENSE-2.0.txt", "LICENSE.txt" # install OSS license

    inreplace "#{bin}/kibana", %r{/node/bin/node}, "/libexec/node/bin/node"
    inreplace "#{bin}/kibana-plugin", %r{/node/bin/node}, "/libexec/node/bin/node"

    cd prefix do
      inreplace "config/kibana.yml", "/var/run/kibana.pid", var/"run/kibana.pid"
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
    end
  end

  def post_install
    ln_s etc/"kibana", prefix/"config"
    (prefix/"data").mkdir
    (prefix/"plugins").mkdir
  end

  def caveats; <<~EOS
    Config: #{etc}/kibana/
    If you wish to preserve your plugins upon upgrade, make a copy of
    #{opt_prefix}/plugins before upgrading, and copy it into the
    new keg location after upgrading.
  EOS
  end

  plist_options :manual => "kibana"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/kibana</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    ENV["BABEL_CACHE_PATH"] = testpath/".babelcache.json"
    assert_match /#{version}/, shell_output("#{bin}/kibana -V")
  end
end

__END__
--- a/src/node_crypto.cc
+++ b/src/node_crypto.cc
@@ -33,15 +33,15 @@
 #include "env-inl.h"
 #include "string_bytes.h"
 #include "util-inl.h"
 #include "v8.h"

 #include <algorithm>
+#include <cmath>
 #include <errno.h>
 #include <limits.h>  // INT_MAX
-#include <math.h>
 #include <stdlib.h>
 #include <string.h>
 #include <vector>

 #define THROW_AND_RETURN_IF_NOT_STRING_OR_BUFFER(val, prefix)                  \
   do {                                                                         \
