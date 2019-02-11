class Libssh < Formula
  desc "C library SSHv1/SSHv2 client and server protocols"
  homepage "https://www.libssh.org/"
  url "https://www.libssh.org/files/0.8/libssh-0.8.6.tar.xz"
  sha256 "1046b95632a07fc00b1ea70ee683072d0c8a23f544f4535440b727812002fd01"
  head "https://git.libssh.org/projects/libssh.git"

  bottle do
    cellar :any
    sha256 "d0676d9d2034f6b2629038b5af7b8b8cac1b45272ee70e4cfc96548f512e9bab" => :mojave
    sha256 "29180a0bf86e1d675df9159bdd63d15a456ede6c59faa9f918cef305d37af4a3" => :high_sierra
    sha256 "cd4709da58264f157e784d1da594a12e96a839e9c1535a1ee656446260fec881" => :sierra
    sha256 "d209ff57eb75e342f1a94fb9b4a396d90fdb2d10955ad52a8cb9e2b475cc0f25" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "openssl"
  unless OS.mac?
    depends_on "python@2" => :build
    depends_on "zlib"
  end

  def install
    mkdir "build" do
      system "cmake", "..", "-DWITH_STATIC_LIB=ON",
                            "-DWITH_SYMBOL_VERSIONING=OFF",
                            *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libssh/libssh.h>
      #include <stdlib.h>
      int main()
      {
        ssh_session my_ssh_session = ssh_new();
        if (my_ssh_session == NULL)
          exit(-1);
        ssh_free(my_ssh_session);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", *("-L#{lib}" if OS.mac?), *("-lssh" if OS.mac?),
           testpath/"test.c", *("-L#{lib}" unless OS.mac?), *("-lssh" unless OS.mac?), "-o", testpath/"test"
    system "./test"
  end
end
