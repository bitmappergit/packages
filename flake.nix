{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/release-23.05;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          config = {
            allowUnfree = true;
          };
        };
      in {
        packages = {
          smlnj = pkgs.callPackage ./SMLNJ/smlnj.nix { };
          squeak = pkgs.callPackage ./Squeak/squeak.nix { };
          opendylan_bin = pkgs.callPackage ./OpenDylan/opendylan_bin.nix { };
          opendylan = pkgs.callPackage ./OpenDylan/opendylan.nix { inherit (self.packages.${system}) opendylan_bin; };
          hop = pkgs.callPackage ./Bigloo/hop.nix { inherit (self.packages.${system}) bigloo; };
          bigloo = pkgs.callPackage ./Bigloo/bigloo.nix { };
          aseprite = pkgs.callPackage ./Other/aseprite.nix { };
          mlkit = pkgs.callPackage ./MLKit/mlkit.nix { };
          massivethreads = pkgs.callPackage ./SMLSharp/massivethreads.nix { };
          smlsharp = pkgs.callPackage ./SMLSharp/smlsharp.nix { inherit (self.packages.${system}) massivethreads; };
          drawterm = pkgs.callPackage ./Misc/drawterm.nix
        };
      });
}
