{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages = {
          smlnj = pkgs.callPackage ./SMLNJ/default.nix { };
          squeak = pkgs.callPackage ./Squeak/default.nix { };
        };
      });
}
