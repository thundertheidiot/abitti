{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/24.11";

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    forAllSystems = fn: lib.genAttrs lib.systems.flakeExposed (system: fn nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: let
      inherit (pkgs) callPackage dockerTools;
    in rec {
      abitti-fs = callPackage ./abitti-fs.nix {};
      nspire = callPackage ./nspire.nix {inherit abitti-fs;};
      maol-content = callPackage ./maol-content.nix {inherit abitti-fs;};
      maol = callPackage ./maol.nix {inherit maol-content;};

      docker = {
        maol = dockerTools.buildLayeredImage {
          name = "maol";
          tag = "latest";
          config = {
            ExposedPorts = {
              "8000" = {};
            };
            Cmd = "${maol}/bin/maol";
          };
        };
      };
    });
  };
}
