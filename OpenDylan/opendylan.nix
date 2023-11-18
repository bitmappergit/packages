{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, perl
, makeWrapper
, binutils
, boehmgc
, opendylan_bin
, llvmPackages_16
}:

stdenv.mkDerivation {
  pname = "opendylan";
  version = "2023.1";

  src = fetchFromGitHub {
    owner = "dylan-lang";
    repo = "opendylan";
    rev = "14325910b61e1cd192649932395de83006a0af26";
    sha256 = "sha256-r1eqDjqfXIy4kfPxoOHFj1jnPOr8EBixr4kCyfle4k0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    makeWrapper
    autoconf
    automake
  ];

  buildInputs = [
    boehmgc
    perl
    opendylan_bin
    llvmPackages_16.llvm
    llvmPackages_16.lld
    llvmPackages_16.clang
    llvmPackages_16.libunwind
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--with-gc=${boehmgc}"
    "CC=${llvmPackages_16.clang}/bin/clang"
    "CXX=${llvmPackages_16.clang}/bin/clang++"
    "LDFLAGS=-fuse-ld=lld"
  ];

  postInstall = ''
    substituteInPlace $out/share/opendylan/build-scripts/config.jam \
      --replace "-lunwind" "-L${llvmPackages_16.libunwind}/lib -lunwind"

    substituteInPlace $out/share/opendylan/build-scripts/posix-build.jam \
      --replace "OBJCOPY   ?= objcopy ;" "OBJCOPY   ?= ${binutils}/bin/objcopy ;" \
      --replace "STRIP     ?= strip ;"   "STRIP     ?= ${binutils}/bin/strip ;"
  '';

  meta = {
    homepage = "https://opendylan.org";
    description = "A multi-paradigm functional and object-oriented programming language";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

