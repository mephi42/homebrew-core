class Meanwhile < Formula
  desc "Open implementation of the Lotus Sametime Community Client protocol"
  homepage "http://meanwhile.sourceforge.net/"
  url "https://dl.fedoraproject.org/pub/fedora/linux/releases/29/Everything/source/tree/Packages/m/meanwhile-1.1.0-25.fc29.src.rpm"
  sha256 "84fe4035e602fbf690fcab1d9e8c7a4b6c335e69683ca23d7744b0077a891705"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "doxygen" => :build
  depends_on "gcc" => :build
  depends_on "glib"
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "quilt" => :build
  depends_on "rpm" => :build

  def install
    system "rpm2cpio <meanwhile-1.1.0-25.fc29.src.rpm | cpio -idv"
    system "tar -xzf meanwhile-1.1.0.tar.gz"
    cd (buildpath / "meanwhile-1.1.0") do
      system "patch -p0 <../meanwhile-crash.patch"
      system "patch -p1 <../meanwhile-fix-glib-headers.patch"
      system "patch -p1 <../meanwhile-file-transfer.patch"
      system "patch -p1 <../meanwhile-status-timestamp-workaround.patch"
      system "patch -p1 <../meanwhile-format-security-fix.patch"

      # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=764494
      ENV["CC"] = "gcc-8"
      ENV.append "CFLAGS", "-fno-tree-vrp"

      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make"

      # make install is not thread-safe
      ENV.deparallelize
      system "make install"
    end
  end
end
