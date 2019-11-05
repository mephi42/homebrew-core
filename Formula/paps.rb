class Paps < Formula
  desc "Pango to PostScript converter"
  homepage "https://github.com/dov/paps"
  url "https://github.com/dov/paps/archive/v0.7.1.tar.gz"
  sha256 "b8cbd16f8dd5832ecfa9907d31411b35a7f12d81a5ec472a1555d00a8a205e0e"

  bottle do
    cellar :any
    rebuild 1
    sha256 "b3a231412edf54dd437eeea7d162344f45c5bbd5b0c59ff0539fb1a9e022d308" => :catalina
    sha256 "11af35b3ae704752dac73a0e5978fb8b02d58f49ec6969800cc974aa22c5b3ff" => :mojave
    sha256 "3b5b4451a527df6fc25bc6671fba73ce636e6040890984aa8fc7d466e9570b52" => :high_sierra
    sha256 "0748d3857e30ea718419eda80c160c8cc4167deee1711c660d106a3a38a5095b" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "glib"
  depends_on "pango"

  def install
    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    pkgshare.install "examples"
  end

  test do
    system bin/"paps", pkgshare/"examples/small-hello.utf8", "--encoding=UTF-8", "-o", "paps.ps"
    assert_predicate testpath/"paps.ps", :exist?
    assert_match "%!PS-Adobe-3.0", (testpath/"paps.ps").read
  end
end
