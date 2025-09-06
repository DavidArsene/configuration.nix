{
  stdenvNoCC,
  fetchgit,
  lib,
  rdfind,
  replaceVars,

  blobs,
  hash ? "",
  tag,
}:
stdenvNoCC.mkDerivation {
  pname = "linux-firmware-minimal";

  src = fetchgit {
    inherit hash tag;
    url = "https://gitlab.com/kernel-firmware/linux-firmware.git";

    sparseCheckout = blobs ++ [ "WHENCE" ];
  };

  nativeBuildInputs = [ rdfind ];

  postUnpack = ''
    patchShebangs .
  '';

  # TODO ------------------ NIX COMPRESSION ALREADY IN UDEV

  buildPhase = replaceVars ''
    ...
  '';

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  meta = with lib; {
    description = "Binary firmware blobs, specifically selected for minimal systems";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    priority = 6; # give precedence to kernel firmware
  };
}
