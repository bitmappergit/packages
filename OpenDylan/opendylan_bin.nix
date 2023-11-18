{ lib, stdenv, fetchurl, patchelf, boehmgc, libunwind, binutils, llvmPackages_16, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "opendylan";
  version = "2023.1";

  src = fetchurl {
    url = "https://github.com/dylan-lang/opendylan/releases/download/v${version}.0/opendylan-${version}-x86_64-linux.tar.bz2";
    sha256 = "sha256-nuWjLJTWYE//HUmAAmzxeNCgxfapgZ8ODXhqnW7Eoik=";
  };

  nativeBuildInputs = [ patchelf boehmgc makeWrapper ];

  buildCommand = ''
    mkdir -p "$out"
    tar --strip-components=1 -xjf "$src" -C "$out"

    interpreter="$(cat "$NIX_CC"/nix-support/dynamic-linker)"
    
    for a in "$out"/bin/*; do
      patchelf --set-interpreter "$interpreter" "$a"
      patchelf --set-rpath "$out/lib:${boehmgc}/lib" "$a"
    done
    
    for a in "$out"/lib/*.so; do
      patchelf --set-rpath "$out/lib:${boehmgc}/lib" "$a"
    done
    
    patch -d $out -p1 < ${./config.jam.patch}
    patch -d $out -p1 < ${./posix-build.jam.patch}

    substituteInPlace $out/share/opendylan/build-scripts/config.jam \
      --replace "nix_clang" "${llvmPackages_16.clang}" \
      --replace "nix_bdwgc" "${boehmgc}" \
      --replace "nix_libunwind" "${llvmPackages_16.libunwind}"

    substituteInPlace $out/share/opendylan/build-scripts/posix-build.jam \
      --replace "nix_binutils" "${binutils}"

    rm -f \
      $out/bin/clang \
      $out/bin/clang++ \
      $out/bin/clang-16 \
      $out/bin/clang-cl \
      $out/bin/clang-cpp \
      $out/bin/ld64.lld \
      $out/bin/ld.lld \
      $out/bin/lld \
      $out/bin/lld-link \
      $out/bin/wasm-ld
  '';

  meta = {
    homepage = "https://opendylan.org";
    description = "A multi-paradigm functional and object-oriented programming language";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

