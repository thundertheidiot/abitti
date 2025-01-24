{
  stdenvNoCC,
  abitti-image ? null,
  util-linux,
  sleuthkit,
  fetchzip,
  squashfsTools,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "abitti-fs";

  src =
    if abitti-image != null
    then abitti-image
    else
      fetchzip {
        url = "https://static.abitti.fi/etcher-usb/koe-etcher.zip";
        hash = "sha256-nGTwlyuou3PUnMrdiukAm++ha6jIful4dBj9A4db8yk=";
      };

  nativeBuildInputs = [squashfsTools util-linux sleuthkit];

  unpackPhase = ''
    IMAGE=${
      if abitti-image != null
      then "$src"
      else "$src/koe.img"
    }

    START="$(fdisk --list $IMAGE | grep koe.img2 | cut -d' ' -f3)"
    SIZE="$(fdisk --list $IMAGE | grep koe.img2 | cut -d' ' -f5)"

    dd if=$IMAGE of=part2.img bs=512 skip=$START count=$SIZE

    INODE="$(fls -r part2.img | grep filesystem.squashfs | cut -d' ' -f3 | cut -d':' -f1)"
    icat part2.img $INODE > filesystem.squashfs
  '';

  installPhase = ''
    unsquashfs -no-xattrs -no-exit-code -dest $out filesystem.squashfs
    chmod --recursive 755 $out
  '';

  fixupPhase = "true";
}
