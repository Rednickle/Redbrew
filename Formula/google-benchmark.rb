class GoogleBenchmark < Formula
  desc "C++ microbenchmark support library"
  homepage "https://github.com/google/benchmark"
  url "https://github.com/google/benchmark/archive/v1.4.1.tar.gz"
  sha256 "f8e525db3c42efc9c7f3bc5176a8fa893a9a9920bbd08cef30fb56a51854d60d"
  head "https://github.com/google/benchmark.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "8491adc3b31006bb8140770c4145fb18f3781986d0274317b7516fb8f5702f8a" => :x86_64_linux
  end

  depends_on "cmake" => :build

  needs :cxx11

  def install
    ENV.cxx11
    system "cmake", "-DBENCHMARK_ENABLE_GTEST_TESTS=OFF", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <string>
      #include <benchmark/benchmark.h>
      static void BM_StringCreation(benchmark::State& state) {
        while (state.KeepRunning())
          std::string empty_string;
      }
      BENCHMARK(BM_StringCreation);
      BENCHMARK_MAIN();
    EOS
    flags = [*("-stdlib=libc++" if OS.mac?), "-I#{include}", "-L#{lib}", "-lbenchmark", *("-pthread" if ENV.compiler == :gcc)] + ENV.cflags.to_s.split
    system ENV.cxx, "-o", "test", "test.cpp", *flags
    system "./test"
  end
end
