{
  stdenvNoCC,
  abitti-fs,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "maol-content";

  srcs = null;
  unpackPhase = "true";

  installPhase = ''
    cp -r ${abitti-fs}/usr/local/share/maol-digi/content $out
  '';
}
