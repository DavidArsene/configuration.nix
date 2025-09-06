{ edge, lib, ... }:

let
  pkgs = edge;

  baseKernel = pkgs.linux_6_9;

  cachyosConfigs = pkgs.fetchFromGitHub {
    owner = "CachyOS";
    repo = "linux-cachyos";
    rev = "5bd608d";
    sha256 = "";
  };

  cachyosPatches = pkgs.fetchFromGitHub {
    owner = "CachyOS";
    repo = "kernel-patches";
    rev = "fbff1cb";
    sha256 = "";
  };

  patchesDir = "${cachyosPatches}/${baseKernel.version}/";

  patchNames = lib.sort lib.lessThan (
    lib.filter (n: lib.hasSuffix ".patch" n) (builtins.attrNames (builtins.readDir patchesDir))
  );

  cachyosKernel = pkgs.linuxManualConfig {
    inherit (baseKernel) version modDirVersion src;

    configfile = "${cachyosConfigs}/linux-cachyos-rc/config";

    kernelPatches = map (n: {
      name = n;
      patch = "${patchesDir}/${n}";
    }) patchNames;
  };

in
pkgs.linuxPackagesFor cachyosKernel
