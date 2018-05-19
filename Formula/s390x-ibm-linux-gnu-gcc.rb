require "fileutils"
require "pathname"

class S390xIbmLinuxGnuGcc < Formula
  desc "Crosstool-NG toolchain for s390x-ibm-linux-gnu"
  homepage "https://crosstool-ng.github.io/"
  url "http://ftpmirror.gnu.org/hello/hello-2.10.tar.gz" # TODO: remove
  sha256 "31e066137a962676e89f69d1b65382de95a7ef7d914b8cb956f41ea72e0f516b" # TODO: remove
  version "8.3.0"

  depends_on "crosstool-ng" => :build
  Formula["crosstool-ng"].deps.each do |dep|
    depends_on dep => :build
  end

  def is_usable(path)
    lower = (path / "foo")
    upper = (path / "FOO")
    begin
      FileUtils.touch(lower)
    rescue
      puts "Warning: #{$!}"
      return false
    end
    ok = !upper.exist?
    lower.unlink
    ok
  end

  def install
    if is_usable(buildpath)
      ct_work_dir = buildpath / ".build"
    else
      volume_path = Pathname.new("/tmp/s390x-ibm-linux-gnu-gcc")
      if is_usable(volume_path)
        ct_work_dir = volume_path
      else
        raise <<~EOS
          #{buildpath} and #{volume_path} are case-insensitive or inaccessible.
          Use the following recipe to fix this:

            $ hdiutil create -type SPARSE -fs "Case-sensitive Journaled HFS+" -size 10g -volname s390x-ibm-linux-gnu-gcc /tmp/s390x-ibm-linux-gnu-gcc
            $ hdiutil attach -mountpoint /tmp/s390x-ibm-linux-gnu-gcc -owners on /tmp/s390x-ibm-linux-gnu-gcc.sparseimage
            $ brew install s390x-ibm-linux-gnu-gcc
            $ hdiutil detach /tmp/s390x-ibm-linux-gnu-gcc
            $ rm /tmp/s390x-ibm-linux-gnu-gcc.sparseimage
        EOS
      end
    end

    chdir ct_work_dir do
      # the following config can be generated using ct-ng savedefconfig
      Pathname.new("defconfig").atomic_write <<~EOS
        CT_LOCAL_TARBALLS_DIR="#{HOMEBREW_CACHE}"
        CT_PREFIX_DIR="#{prefix}"
        # CT_PREFIX_DIR_RO is not set
        CT_ARCH_s390=y
        CT_MULTILIB=y
        CT_ARCH_64=y
        CT_KERNEL_linux=y
        CT_BINUTILS_PLUGINS=y
        CT_COMP_TOOLS_automake=y
        CT_CC_GCC_VERSION=#{version}
      EOS
      ENV.delete("CC")  # fix "libtool:   error: specify a tag with '--tag'" during "Installing libiconv for host"
      ENV.delete("CXX")
      system "env"
      system "ct-ng", "defconfig"
      system "ct-ng", "build"
    end
  end
end
