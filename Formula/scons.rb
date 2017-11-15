class Scons < Formula
  desc "Substitute for classic 'make' tool with autoconf/automake functionality"
  homepage "http://www.scons.org"
  url "https://downloads.sourceforge.net/project/scons/scons/3.0.1/scons-3.0.1.tar.gz"
  sha256 "24475e38d39c19683bc88054524df018fe6949d70fbd4c69e298d39a0269f173"

  bottle do
    cellar :any_skip_relocation
    sha256 "c791b4905477a5fbc33345cef5e412807ffc90ba6ea35bfc9a263f542702aa1c" => :high_sierra
    sha256 "c791b4905477a5fbc33345cef5e412807ffc90ba6ea35bfc9a263f542702aa1c" => :sierra
    sha256 "c791b4905477a5fbc33345cef5e412807ffc90ba6ea35bfc9a263f542702aa1c" => :el_capitan
  end

  # Remove for > 3.0.0
  # Upstream commit from 20 Sep 2017 "Support python 2 print statements in SConscripts"
  patch :p2 do
    url "https://github.com/SConsProject/scons/commit/2e0de3c5.patch?full_index=1"
    sha256 "ca9348417478a729f6fdaae62cc25d73a30371c4d467415196246f1d0dcfd195"
  end

  depends_on :python unless OS.mac?

  def install
    inreplace "engine/SCons/Platform/posix.py",
      "env['ENV']['PATH']    = '/usr/local/bin:/opt/bin:/bin:/usr/bin'",
      "env['ENV']['PATH']    = '#{HOMEBREW_PREFIX}/bin:/usr/local/bin:/opt/bin:/bin:/usr/bin'" \
      if OS.linux?

    man1.install gzip("scons-time.1", "scons.1", "sconsign.1")
    system (OS.mac? ? "/usr/bin/python" : "python"), "setup.py", "install",
             "--prefix=#{prefix}",
             "--standalone-lib",
             # SCons gets handsy with sys.path---`scons-local` is one place it
             # will look when all is said and done.
             "--install-lib=#{libexec}/scons-local",
             "--install-scripts=#{bin}",
             "--install-data=#{libexec}",
             "--no-version-script", "--no-install-man"

    # Re-root scripts to libexec so they can import SCons and symlink back into
    # bin. Similar tactics are used in the duplicity formula.
    bin.children.each do |p|
      mv p, "#{libexec}/#{p.basename}.py"
      bin.install_symlink "#{libexec}/#{p.basename}.py" => p.basename
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      int main()
      {
        printf("Homebrew");
        return 0;
      }
    EOS
    (testpath/"SConstruct").write "Program('test.c')"
    system bin/"scons"
    assert_equal "Homebrew", shell_output("#{testpath}/test")
  end
end
