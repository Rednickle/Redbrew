class Tbb < Formula
  desc "Rich and complete approach to parallelism in C++"
  homepage "https://www.threadingbuildingblocks.org/"
  url "https://github.com/intel/tbb/archive/v2020.2.tar.gz"
  version "2020_U2"
  sha256 "4804320e1e6cbe3a5421997b52199e3c1a3829b2ecb6489641da4b8e32faf500"

  bottle do
    cellar :any
    rebuild 1
    sha256 "d601aa195a3baf397390550894de8d39e6602a082154fa5facdfcbe64e3abffc" => :catalina
    sha256 "2e1004341c9ea81972212ce180a258bc162528b6eac46e67c8bc03538c3cfe40" => :mojave
    sha256 "e1efb8aec2b87e2facdb824971718d6fa531caa5043b10e811dc86a6c5e1e797" => :high_sierra
    sha256 "0fc77ed241a54a80f9034ae5c581d17f5cc6071f4852406c21f0cd6dac3507fa" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "swig" => :build
  depends_on "python@3.8"

  def install
    compiler = (ENV.compiler == :clang) ? "clang" : "gcc"
    args = %W[tbb_build_prefix=BUILDPREFIX compiler=#{compiler}]

    # Fix /usr/bin/ld: cannot find -lirml by building rml
    system "make", "rml", *args unless OS.mac?

    system "make", *args
    if OS.mac?
      lib.install Dir["build/BUILDPREFIX_release/*.dylib"]
    else
      lib.install Dir["build/BUILDPREFIX_release/*.so*"]
    end

    # Build and install static libraries
    system "make", "tbb_build_prefix=BUILDPREFIX", "compiler=#{compiler}",
                   "extra_inc=big_iron.inc"
    lib.install Dir["build/BUILDPREFIX_release/*.a"]
    include.install "include/tbb"

    cd "python" do
      ENV["TBBROOT"] = prefix
      system Formula["python@3.8"].opt_bin/"python3", *Language::Python.setup_install_args(prefix)
    end

    system "cmake", *std_cmake_args,
                    "-DINSTALL_DIR=lib/cmake/TBB",
                    "-DSYSTEM_NAME=Darwin",
                    "-DTBB_VERSION_FILE=#{include}/tbb/tbb_stddef.h",
                    "-P", "cmake/tbb_config_installer.cmake"

    (lib/"cmake"/"TBB").install Dir["lib/cmake/TBB/*.cmake"]
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <tbb/task_scheduler_init.h>
      #include <iostream>

      int main()
      {
        std::cout << tbb::task_scheduler_init::default_num_threads();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}", "-ltbb", "-o", "test"
    system "./test"
  end
end
