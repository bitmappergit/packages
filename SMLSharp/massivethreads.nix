{ lib, stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "massivethreads";
  version = "1.00";

  src = fetchFromGitHub {
    owner = "massivethreads";
    repo = "massivethreads";
    rev = "v${version}";
    sha256 = "sha256-0CNXqc5jEsOw6H2QQj0e0Akl1z+sn8ooFwnb+YXrIzU=";
  };

  # nativeBuildInputs = [ autoreconfHook ];

  patches = [ ./glibc.patch ];

  meta = with lib; {
    description = "Light weight thread library";
    homepage = "https://massivethreads.github.io/";
    license = licenses.bsd2;
    platforms = platforms.unix;
    # maintainers = with maintainers; [ bitmapper ];
  };
}
