{ lib, stdenv, fetchurl, Libsystem ? null }:
let
  version = "110.99.4";
  baseurl = "http://smlnj.cs.uchicago.edu/dist/working/${version}";

  arch = if stdenv.is64bit then "64" else "32";

  boot32 = {
    url = "${baseurl}/boot.x86-unix.tgz";
    sha256 = "sha256-7ZtEU5aQI64D0t21DoX6HNeRoYVSixbbx5rGvcH5yWI=";
  };
  boot64 = {
    url = "${baseurl}/boot.amd64-unix.tgz";
    sha256 = "sha256-nzgwI1SmY6qDAuCw+KZkVwpAJ1W22+VTCW/i3/kEjD4=";
  };

  bootBinary = if stdenv.is64bit then boot64 else boot32;

  sources = map fetchurl [
    bootBinary
    {
      url = "${baseurl}/config.tgz";
      sha256 = "sha256-FhM11xcp1pVU61QrNfa2miaAx/vxk9qHh/otPwIB2eg=";
    }
    {
      url = "${baseurl}/cm.tgz";
      sha256 = "sha256-33+9h5DP9HLsEeceq/t3a2sbnIWCD9jggQB/1rS3qCc=";
    }
    {
      url = "${baseurl}/compiler.tgz";
      sha256 = "sha256-GcJSd4kDtwPownqKGacu3RgrSX8dxL08poTuSuBtis0=";
    }
    {
      url = "${baseurl}/runtime.tgz";
      sha256 = "sha256-qnraM/c1luZfbxtv7j+RFKrw1QqT1pywJHGlgoFlyRg=";
    }
    {
      url = "${baseurl}/system.tgz";
      sha256 = "sha256-qB2/vmuOkiy7ofW1oIpBL4nrzK0GbwBfXJ8Caot9VQs=";
    }
    {
      url = "${baseurl}/MLRISC.tgz";
      sha256 = "sha256-8rxulE75l29/aE1yQpXJGmyLk+Y4lC2dykGdxIp2xFM=";
    }
    {
      url = "${baseurl}/smlnj-lib.tgz";
      sha256 = "sha256-UP7mO3xbZNK7kMJPbWKFBVTBd4m1N1z4AVFIHHNCw2w=";
    }
    {
      url = "${baseurl}/old-basis.tgz";
      sha256 = "sha256-BdxFNXaZFZNK8uDwnZcvLLprF8DvNKqcnlZd9NgXFtQ=";
    }
    {
      url = "${baseurl}/ckit.tgz";
      sha256 = "sha256-sam6602OWpIaafOcekSroDcZEM4n31IVtc05m+upqSI=";
    }
    {
      url = "${baseurl}/nlffi.tgz";
      sha256 = "sha256-gId/fQC9ln5LOa2M2drZKQ3JSFkAhAstEwVIdWy8VdY=";
    }
    {
      url = "${baseurl}/cml.tgz";
      sha256 = "sha256-0KGA7wL2fPHQDFPZElkYd2H0NF4u8ajNvojYf3uFA18=";
    }
    {
      url = "${baseurl}/eXene.tgz";
      sha256 = "sha256-vibIh+6DfHQyhHqu+kGnZ5tdOaCtEvnhssrIVzaQTuY=";
    }
    {
      url = "${baseurl}/ml-lpt.tgz";
      sha256 = "sha256-8vajt/QJtzm1jTQdB5aKrqHPMpPIlHBMnXTjccG0fZU=";
    }
    {
      url = "${baseurl}/ml-lex.tgz";
      sha256 = "sha256-Z0NJgOZqXRFFSVoNwXPOE5pNBXD2NqNsW7Zv/71Cl3g=";
    }
    {
      url = "${baseurl}/ml-yacc.tgz";
      sha256 = "sha256-tpbMDBy75jWzrmfcSqZ4pEDF1LsAHpP+8tul3+yvLDI=";
    }
    {
      url = "${baseurl}/ml-burg.tgz";
      sha256 = "sha256-yu+8YITTgdeks4/ldU9GF6MZwdX1hLUHXOT8FvdDb1M=";
    }
    {
      url = "${baseurl}/pgraph.tgz";
      sha256 = "sha256-t1zLKcvQdYVLxHdBH3QAMwP4oT7prULznCBWlmX58l0=";
    }
    {
      url = "${baseurl}/trace-debug-profile.tgz";
      sha256 = "sha256-JNG82x96lxLXPVN/RtU/l0jnPo8rlWeuDRkPJtGtdYk=";
    }
    {
      url = "${baseurl}/heap2asm.tgz";
      sha256 = "sha256-FFrHiznDrzITe6uFup7kqygUSLvPJRrVVJDCgIugf38=";
    }
    {
      url = "${baseurl}/smlnj-c.tgz";
      sha256 = "sha256-ZZfROSJ4WYwYxkW13Etm3AzahFLcJOi6LiMQkPrsWsk=";
    }
    {
      url = "${baseurl}/doc.tgz";
      sha256 = "sha256-VIl86+dJaDyuzbN1c3/zk9ez44xiLTSCNWN4VLZF2Kk=";
    }
    {
      url = "${baseurl}/asdl.tgz";
      sha256 = "sha256-PkhQui/2o3xdZFwEwsQRRSRkrFFjgKIvspSv9PTosd0=";
    }
  ];
in stdenv.mkDerivation {
  pname = "smlnj";

  inherit version;

  inherit sources;

  patchPhase = ''
    sed -i '/^PATH=/d' config/_arch-n-opsys base/runtime/config/gen-posix-names.sh
    echo SRCARCHIVEURL="file:/$TMP" > config/srcarchiveurl
    patch -p1 < ${./targets.patch}
  '' + lib.optionalString stdenv.isDarwin ''
    # Locate standard headers like <unistd.h>
    substituteInPlace base/runtime/config/gen-posix-names.sh \
      --replace "\$SDK_PATH/usr" "${Libsystem}"
  '';

  unpackPhase = ''
    for s in $sources; do
      b=$(basename $s)
      cp $s ''${b#*-}
    done
    unpackFile config.tgz
    mkdir base
    ./config/unpack $TMP runtime
  '';

  buildPhase = ''
    ./config/install.sh -default ${arch}
  '';

  installPhase = ''
    mkdir -pv $out
    cp -rv bin lib $out

    cd $out/bin
    for i in *; do
      sed -i "2iSMLNJ_HOME=$out/" $i
    done
  '';

  meta = with lib; {
    description = "Standard ML of New Jersey, a compiler";
    homepage = "http://smlnj.org";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" ];
    maintainers = with maintainers; [ thoughtpolice ];
    mainProgram = "sml";
    # never built on x86_64-darwin since first introduction in nixpkgs
    broken = stdenv.isDarwin && stdenv.isx86_64;
  };
}
