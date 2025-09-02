# very WIP, this does not work yet
{
  stdenvNoCC,
  abitti-fs,
  jre8,
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
      export JAVA_HOME=${jre8.jre}/lib/openjdk/jre

      if [ ! -d \"\$WINEPREFIX\" ]; then
        cp -rv $out/wineprefix \$WINEPREFIX
        ${winetricks}/bin/winetricks --quiet --force vcrun2015 java
        ${wineWow64Packages.staging}/bin/wine $out/resources/vc_redist.x86.exe /q

        cp -rv \"$out/TI Education\" \"\$WINEPREFIX/drive_c/Program Files/\"
      fi

      # ${wineWow64Packages.staging}/bin/wine $out/TI\ Education/TI-Nspire\ CX\ CAS\ Student\ Software/TI-Nspire\ CX\ CAS\ Student\ Software.exe
      ${wineWow64Packages.staging}/bin/wine \"\$WINEPREFIX/drive_c/Program Files/TI Education/TI-Nspire CX CAS Student Software/TI-Nspire CX CAS Student Software.exe\"
    '';
  in ''
    mkdir -p $out/bin

    cp -r "${abitti-fs}/opt/TINspireCXCASStudentSoftware/.wine/drive_c/Program Files/TI Education" $out
    chmod --recursive 755 "$out/TI Education"
    cp -r "${abitti-fs}/opt/TINspireCXCASStudentSoftware/resources" $out/resources

    echo "${script}" > $out/bin/ti-nspire
    chmod +x $out/bin/ti-nspire
  '';

  fixupPhase = "true";
}
