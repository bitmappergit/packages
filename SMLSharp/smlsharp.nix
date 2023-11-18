{ lib, stdenv, fetchFromGitHub, gmp, massivethreads, llvm }:

stdenv.mkDerivation rec {
  pname = "smlsharp";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "smlsharp";
    repo = "smlsharp";
    rev = "v${version}";
    sha256 = "sha256-chGwMSsrKHUWQHce/UhcrOWw+x9vcMCG2+nk+RW5lzM=";
  };

  buildInputs = [
    gmp
    massivethreads
    llvm
  ];

  meta = with lib; {
    description = "SML# compiler";
    homepage = "https://smlsharp.github.io/";
    license = licenses.mit;
    platforms = platforms.unix;
    # maintainers = with maintainers; [ bitmapper ];
  };
}
