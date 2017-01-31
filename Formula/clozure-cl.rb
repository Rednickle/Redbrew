class ClozureCl < Formula
  desc "Common Lisp implementation with a long history"
  homepage "http://ccl.clozure.com/"
  version "1.11"

  if OS.mac?
    url "http://ccl.clozure.com/ftp/pub/release/1.11/ccl-1.11-darwinx86.tar.gz"
    sha256 "2fc4b519f26f7df3fbb62314b15bd5d098082b05d40c3539f8204aa10f546913"
    head "http://svn.clozure.com/publicsvn/openmcl/trunk/darwinx86/ccl"
  elsif OS.linux?
    url "http://ccl.clozure.com/ftp/pub/release/1.11/ccl-1.11-linuxx86.tar.gz"
    sha256 "08e885e8c2bb6e4abd42b8e8e2b60f257c6929eb34b8ec87ca1ecf848fac6d70"
    head "http://svn.clozure.com/publicsvn/openmcl/trunk/linuxx86/ccl"
  end

  bottle :unneeded

  conflicts_with "cclive", :because => "both install a ccl binary"

  def install
    ENV["CCL_DEFAULT_DIRECTORY"] = buildpath
    system "scripts/ccl64", "-n",
           "-e", "(ccl:rebuild-ccl :full t)",
           "-e", "(quit)"

    # Get rid of all the .svn directories
    rm_rf Dir["**/.svn"]

    prefix.install "doc/README"
    doc.install Dir["doc/*"]

    libexec.install Dir["*"]
    bin.install libexec/"scripts/ccl64"
    bin.env_script_all_files(libexec/"bin", :CCL_DEFAULT_DIRECTORY => libexec)
    bin.install_symlink bin/"ccl64" => "ccl"
  end

  test do
    args = "-n -e '(write-line (write-to-string (* 3 7)))' -e '(quit)'"
    assert_equal "21", shell_output("#{bin}/ccl #{args}").strip
  end
end
