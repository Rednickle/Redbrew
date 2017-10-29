class Hypre < Formula
  desc "Library featuring parallel multigrid methods for grid problems"
  homepage "https://computation.llnl.gov/casc/hypre/software.html"
  url "https://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download/hypre-2.11.2.tar.gz"
  sha256 "25b6c1226411593f71bb5cf3891431afaa8c3fd487bdfe4faeeb55c6fdfb269e"
  revision 1
  head "https://github.com/LLNL/hypre.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "e0d1c37af0624bd9c7638bd1288c9cc523160ceabeecceb7534bed6bdf0248df" => :high_sierra
    sha256 "bc90328c270fde57f6c1966ef076f095455d5297c4a996db79f44cd4e7258e11" => :sierra
    sha256 "302d24880cb100ea35d51961c01992fb4acc151f88a760703443928c5739ea9f" => :el_capitan
  end

  option "without-accelerate", "Build without Accelerate framework (use internal BLAS routines)"

  depends_on "veclibfort" if build.without?("openblas") && OS.mac?
  depends_on :fortran
  depends_on :mpi => [:cc, :cxx, :f90, :f77]
  depends_on "openblas" => :recommended unless OS.mac?

  def install
    cd "src" do
      config_args = ["--prefix=#{prefix}"]

      ENV["CC"] = ENV["MPICC"]
      ENV["CXX"] = ENV["MPICXX"]

      if build.with? "openblas"
        config_args += ["--with-blas=yes",
                        "--with-blas-libs=openblas",
                        "--with-blas-lib-dirs=#{Formula["openblas"].opt_lib}",
                        "--with-lapack=yes",
                        "--with-lapack-libs=openblas",
                        "--with-lapack-lib-dirs=#{Formula["openblas"].opt_lib}"]
      elsif build.with? "accelerate"
        config_args += ["--with-blas=yes",
                        "--with-blas-libs=blas cblas",
                        "--with-blas-lib-dirs=/usr/lib",
                        "--with-lapack=yes",
                        "--with-lapack-libs=lapack clapack f77lapack",
                        "--with-lapack-lib-dirs=/usr/lib"]
      end

      if OS.linux?
        # on Linux Homebrew formulae will fail to build
        # shared libraries without the dependent static libraries
        # compiled with -fPIC
        ENV.prepend "CFLAGS", "-fPIC"
        ENV.prepend "CXXFLAGS", "-fPIC"
        ENV.prepend "FFLAGS", "-fPIC"
      end

      # MPI library strings for linking depends on compilers
      # enabled.  Only the C library strings are needed (without the
      # lib), because hypre is a C library.
      config_args += ["--with-MPI",
                      "--with-MPI-include=#{HOMEBREW_PREFIX}/include",
                      "--with-MPI-lib-dirs=#{HOMEBREW_PREFIX}/lib",
                      "--with-MPI-libs=mpi"]
      config_args << "--enable-bigint"
      system "./configure", *config_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "HYPRE_struct_ls.h"
      int main(int argc, char* argv[]) {
        HYPRE_StructGrid grid;
      }
    EOS

    system ENV.cxx, "test.cpp", "-o", "test"
    system "./test"
  end
end
