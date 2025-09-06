{
  fetchzip,
  lib,
  stdenvNoCC,
  autoPatchelfHook,

  pkgs' ? { },
  config' ? { },

  libfprint-tod,
}:

stdenvNoCC.mkDerivation rec {
  pname = "libfprint-2-tod1-fpc";
  version = "27.26.23.39";

  src = fetchzip {
    url = "https://download.lenovo.com/pccbbs/mobiles/r1slm02w.zip";
    hash = "sha256-/buXlp/WwL16dsdgrmNRxyudmdo9m1HWX0eeaARbI3Q=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ libfprint-tod ];

  installPhase = ''
    install -D -m 644 FPC_driver_linux_${version}/*/libfpcbep.so -t "$out/lib/libfprint-2/tod-1/"
    install -D -m 644 FPC_driver_linux_libfprint/*/lib/udev/rules.d/* -t "$out/lib/udev/rules.d/"
  '';

  passthru.driverPath = "/lib/libfprint-2/tod-1";

  meta = with lib; {
    description = "FPC (10a5:9800) driver module for libfprint-2-tod Touch OEM Driver (from Lenovo)";
    homepage = "https://support.lenovo.com/us/en/downloads/ds563477-fpc-fingerprint-driver-for-ubuntu-2004-ubuntu-2204-thinkpad-e14-gen-4-e15-gen-4";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
// lib.optionalAttrs false {
  # Usage example:

  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = (pkgs'.callPackage ./libfprint-2-tod1-fpc.nix { });
  };

  services.udev.packages = [ config'.services.fprintd.tod.driver ];
}
