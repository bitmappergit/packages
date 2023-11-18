{ stdenv
, lib
, fetchgit
, xorg
}:

stdenv.mkDerivation rec {
  pname = "drawterm";
  version = "unstable-2023-09-03";

  src = fetchgit {
    url = "git://git.9front.org/plan9front/drawterm";
    rev = "c4ea4d299aa1bbbcc972c04adf06c18245ce7674";
    sha256 = "sha256-Tp3yZb1nteOlz/KhydFdjBrj3OrY20s/Ltfk/EBrIyk=";
  };

  buildInputs = [
    xorg.libX11
    xorg.libXt
  ];

  # TODO: macos
  makeFlags = [ "CONF=unix" ];

  installPhase = ''
    install -Dm755 -t $out/bin/ drawterm
    install -Dm644 -t $out/man/man1/ drawterm.1
  '';

  meta = with lib; {
    description = "Connect to Plan9 CPU servers from other operating systems.";
    homepage = "https://drawterm.9front.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ luc65r ];
    platforms = platforms.linux;
  };
}

