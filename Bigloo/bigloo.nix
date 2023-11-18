{ fetchurl
, lib
, stdenv
, autoconf
, automake
, libtool
, gmp
, which
, file
, libunistring
, boehmgc
, openssl
}:

stdenv.mkDerivation rec {
  pname = "bigloo";
  version = "4.5a-1";

  src = fetchurl {
    url = "ftp://ftp-sop.inria.fr/indes/fp/Bigloo/bigloo-${version}.tar.gz";
    sha256 = "sha256-2PBOiJk2GH3FGXGbdJrQP+V0FloLbTGOVh8bO84NWAg=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    which
    file
  ];

  buildInputs = [
    boehmgc
    openssl
  ];

  propagatedBuildInputs = [
    gmp
  ];

  configureFlags = [
    "--enable-ssl"
  ];

  #preConfigure =
  #  # For libuv on darwin
  #  lib.optionalString stdenv.isDarwin ''
  #    export LIBTOOLIZE=libtoolize
  #  '' +
  #  # Help libgc's configure.
  #  '' export CXXCPP="$CXX -E"
  #  '';

  patchPhase = ''
    # Fix absolute paths.
    sed -e 's=/bin/mv=mv=g' \
        -e 's=/bin/rm=rm=g' \
        -e 's=/usr/bin/file=file=g' \
        -e 's=/tmp=$TMPDIR=g' \
        -i \
        autoconf/* \
        [Mm]akefile* \
        */[Mm]akefile* \
        */*/[Mm]akefile* \
        */*/*/[Mm]akefile* \
        */*/*/*/[Mm]akefile* \
        comptime/Cc/cc.scm \
        gc/install-*

    # Make sure we don't change string lengths in the generated
    # C files.
    sed -e 's=/bin/rm=     rm=g' -e 's=/bin/mv=     mv=g'	\
        -i comptime/Cc/cc.c
  '';

  checkTarget = "test";

  # Hack to avoid TMPDIR in RPATHs.
  preFixup = ''rm -rf "$(pwd)"'';

  meta = {
    description = "Efficient Scheme compiler";
    homepage    = "http://www-sop.inria.fr/indes/fp/Bigloo/";
    license     = lib.licenses.gpl2Plus;
    platforms   = lib.platforms.unix;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    broken      = stdenv.isDarwin && stdenv.isAarch64; # segfault during build

    longDescription = ''
      Bigloo is a Scheme implementation devoted to one goal: enabling
      Scheme based programming style where C(++) is usually
      required.  Bigloo attempts to make Scheme practical by offering
      features usually presented by traditional programming languages
      but not offered by Scheme and functional programming.  Bigloo
      compiles Scheme modules.  It delivers small and fast stand alone
      binary executables.  Bigloo enables full connections between
      Scheme and C programs, between Scheme and Java programs, and
      between Scheme and C# programs.
    '';
  };
}

