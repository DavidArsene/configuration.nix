{
  stdenv,
  pkgs,
  lib,
  configPath ? ./config-nix/cachyos-rc.x86_64-linux.nix,
  ogKernelConfigfile ? pkgs.linuxPackages.kernel.passthru.configfile,
  # those are set in their PKGBUILDs
  kernelPatches ? { },
}:

let
  versions = lib.trivial.importJSON ./versions-rc.json;

  # The three phases of the config
  # - First we apply the changes fromt their PKGBUILD using kconfig;
  # - Then we NIXify it (in the update-script);
  # - Last state is importing the NIXified version for building.
  preparedConfigfile = pkgs.callPackage ./prepare.nix {
    inherit
      stdenv
      kernel
      ogKernelConfigfile
      pkgs
      versions
      ;
  };
  linuxConfigTransfomed = import configPath;

  kernel =
    (pkgs.linuxManualConfig {
      config = linuxConfigTransfomed;
      src = preparedConfigfile.src;

      modDirVersion = lib.versions.pad 3 "${versions.linux.version}${versions.suffix}";

      allowImportFromDerivation = false;

      kernelPatches =
        kernelPatches
        ++ builtins.map (filename: {
          name = builtins.baseNameOf filename;
          patch = filename;
        }) preparedConfigfile.passthru.kernelPatches;

    }).overrideAttrs
      (prevAttrs: {
        postPatch = prevAttrs.postPatch + preparedConfigfile.extraVerPatch;
        # bypasses https://github.com/NixOS/nixpkgs/issues/216529
        passthru = prevAttrs.passthru // {
          # inherit kconfigToNix;
          features = {
            efiBootStub = true;
            ia32Emulation = true;
            netfilterRPFilter = false; # true;
          };
        };
      });

  # CachyOS repeating stuff.
  # addOurs = _finalAttrs: prevAttrs: {
  #   kernel_configfile = prevAttrs.kernel.configfile;
  # };

  # basePackages = pkgs.linuxPackagesFor kernel;
  # packagesWithOurs = basePackages.extend addOurs;
  # packagesWithRemovals = removeAttrs packagesWithOurs [
  #   "lkrg"
  #   "drbd"
  # ];

  packages =
    (pkgs.linuxPackagesFor kernel).extend (
      finalAttrs: prevAttrs: {
        kernel_configfile = prevAttrs.kernel.configfile;
      }
    )
    |> removeAttrs [
      "lkrg"
      "drbd"
    ];
in
packages
// {
  _version = versions.linux.version;
}
