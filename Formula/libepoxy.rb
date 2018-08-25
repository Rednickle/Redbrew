class Libepoxy < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  url "https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.2.tar.xz"
  sha256 "a9562386519eb3fd7f03209f279f697a8cba520d3c155d6e253c3e138beca7d8"

  bottle do
    cellar :any
    sha256 "20c457ac30badc18f3b02c37ba8dfe865773fd5c50aa0ce3ac550581014bceae" => :mojave
    sha256 "0748efd9737fe67c0b55dc6b21b927e20b3e816eb44813b99d76b2c1dd301008" => :high_sierra
    sha256 "815b406da30c03dc46621d217e5fd0e2b7de30194f455943e214afa397dc68bc" => :sierra
    sha256 "a1d5c559a7a5c84316b2adb75fab79297b27ecb301bf60ef6cd69baf8a367158" => :el_capitan
    sha256 "0b2bb0de01ef607390f28e9d7e8053bc98a506b206ccde0a172cdbcf8fa95573" => :x86_64_linux
  end

  depends_on "meson-internal" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@2" => :build
  unless OS.mac?
    depends_on "freeglut"
    depends_on "linuxbrew/xorg/mesa"
    depends_on "linuxbrew/xorg/xorg"
    depends_on "linuxbrew/xorg/damageproto"
    depends_on "linuxbrew/xorg/fixesproto"
    depends_on "linuxbrew/xorg/kbproto"
    depends_on "linuxbrew/xorg/xf86vidmodeproto"
    depends_on "linuxbrew/xorg/xextproto"
  end

  def install
    # Fix "Couldn't open libOpenGL.so.0: dlopen(libOpenGL.so.0, 5): image not found"
    # Reported 29 May 2018 https://github.com/anholt/libepoxy/issues/176
    inreplace "src/dispatch_common.c", '#define OPENGL_LIB "libOpenGL.so.0"', ""

    ENV.refurbish_args

    mkdir "build" do
      system "meson", "--prefix=#{prefix}", *("--libdir=#{lib}" unless OS.mac?), ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS

      #include <epoxy/gl.h>
      #ifdef OS_MAC
      #include <OpenGL/CGLContext.h>
      #include <OpenGL/CGLTypes.h>
      #endif
      int main()
      {
          #ifdef OS_MAC
          CGLPixelFormatAttribute attribs[] = {0};
          CGLPixelFormatObj pix;
          int npix;
          CGLContextObj ctx;

          CGLChoosePixelFormat( attribs, &pix, &npix );
          CGLCreateContext(pix, (void*)0, &ctx);
          #endif

          glClear(GL_COLOR_BUFFER_BIT);
          #ifdef OS_MAC
          CGLReleasePixelFormat(pix);
          CGLReleaseContext(pix);
          #endif
          return 0;
      }
    EOS
    args = %w[-lepoxy]
    args += %w[-framework OpenGL -DOS_MAC] if OS.mac?
    args += %w[-o test]
    system ENV.cc, "test.c", *args
    system "ls", "-lh", "test"
    system "file", "test"
    system "./test"
  end
end
