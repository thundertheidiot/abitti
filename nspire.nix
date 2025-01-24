{
  stdenvNoCC,
  abitti-fs,
  writeShellScript,
  winetricks,
  wineWow64Packages,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "ti-nspire";

  srcs = [];
  unpackPhase = "true";

  buildInputs = [
    wineWow64Packages.staging
    winetricks
  ];

  installPhase = let
    script = ''
      #!/bin/sh
      export WINEPREFIX=\"\''${XDG_DATA_HOME:-\$HOME/.local/share}/wineprefixes/ti-nspire\"
      export WINEDLLOVERRIDES=mscoree,mshtml=

      if [ ! -d \"\$WINEPREFIX\" ]; then
        cp -rv $out/wineprefix \$WINEPREFIX
        ${winetricks}/bin/winetricks --quiet --force vcrun2015
        ${wineWow64Packages.staging}/bin/wine $out/resources/vc_redist.x86.exe /q
      fi

      ${wineWow64Packages.staging}/bin/wine \"\$WINEPREFIX/drive_c/Program Files/TI Education/TI-Nspire CX CAS Student Software/TI-Nspire CX CAS Student Software.exe\"
    '';
  in ''
    mkdir -p $out/bin

    cp -r "${abitti-fs}/opt/TINspireCXCASStudentSoftware/.wine" $out/wineprefix
    cp -r "${abitti-fs}/opt/TINspireCXCASStudentSoftware/resources" $out/resources

    echo "${script}" > $out/bin/ti-nspire
    chmod +x $out/bin/ti-nspire
  '';

  fixupPhase = "true";
}
