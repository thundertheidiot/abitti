# Abitti extractor

This nix flake offers packages to easily access stuff shipped with the finnish Abitti (1) exam system.

## MAOL

Run `nix run .#maol` and go to http://localhost:8000 to access MAOL.

A docker image can be built with `nix build .#docker.maol`.
