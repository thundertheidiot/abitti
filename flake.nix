{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    forAllSystems = fn: lib.genAttrs lib.systems.flakeExposed (system: fn nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: let
      inherit (pkgs) callPackage;
      inherit (builtins) pathExists;
    in rec {
      abitti-fs =
        if pathExists ./koe.img
        then callPackage ./abitti-fs.nix {abitti-image = ./koe.img;}
        else callPackage ./abitti-fs.nix {};

      nspire = callPackage ./nspire.nix {inherit abitti-fs;};
      maol-content = callPackage ./maol-content.nix {inherit abitti-fs;};
      maol = callPackage ./maol.nix {inherit maol-content;};

      docker = let
        inherit (pkgs) dockerTools stdenv;
      in {
        maol = dockerTools.buildImage {
          name = "maol";
          tag = "latest";

          config = {
            ExposedPorts = {
              "8000/tcp" = {};
            };
            Cmd = "${maol}/bin/maol";
          };

          runAsRoot = ''
            #!${stdenv.shell}
            ${dockerTools.shadowSetup}
            groupadd --system nobody
            useradd --system --gid nobody nobody
          '';
        };
      };
    });
  };
}
