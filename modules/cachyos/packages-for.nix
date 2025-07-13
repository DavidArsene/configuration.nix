{
  stdenv,
  pkgs,
  taste,
  configPath,
  versions,
  ogKernelConfigfile ? pkgs.linuxPackages.kernel.passthru.configfile,
  # those are set in their PKGBUILDs
  # kernelPatches ? { },
  basicCachy ? true,
  mArch ? null,
  cpuSched ? "cachyos",
  ticksHz ? 500,
  tickRate ? "full",
  preempt ? "full",
  hugePages ? "always",
  withDAMON ? false,
  withNTSync ? true,
  withHDR ? true,
  withoutDebug ? false,
  description ? "Linux EEVDF-BORE scheduler Kernel by CachyOS with other patches and improvements",
}:

let
  cachyConfig = {
    inherit
      taste
      versions
      basicCachy
      mArch
      cpuSched
      ticksHz
      tickRate
      preempt
      hugePages
      withDAMON
      withNTSync
      withHDR
      withoutDebug
      description
      ;
  };

  # The three phases of the config
  # - First we apply the changes fromt their PKGBUILD using kconfig;
  # - Then we NIXify it (in the update-script);
  # - Last state is importing the NIXified version for building.
  preparedConfigfile = pkgs.callPackage ./prepare.nix {
    inherit
      cachyConfig
      stdenv
      kernel
      ogKernelConfigfile
      ;
  };
  linuxConfigTransfomed = import configPath;

  kernel = pkgs.callPackage ./kernel.nix {
    inherit cachyConfig stdenv;
    kernelPatches = [ ];
    configfile = preparedConfigfile;
    config = linuxConfigTransfomed;
  };

  # CachyOS repeating stuff.
  addOurs = _finalAttrs: prevAttrs: {
    kernel_configfile = prevAttrs.kernel.configfile;
  };

  basePackages = pkgs.linuxPackagesFor kernel;
  packagesWithOurs = basePackages.extend addOurs;
  packagesWithRemovals = removeAttrs packagesWithOurs [
    "lkrg"
    "drbd"
  ];
  # packagesWithRemovals.meta = {
  #   platforms = [ "x86_64-linux" ];
  # };
  versionSuffix = "+C${builtins.substring 0 6 versions.config.rev}+P${builtins.substring 0 6 versions.patches.rev}";
in
packagesWithRemovals
// {
  _description = "Kernel and modules for ${description}";
  _version = "${versions.linux.version}${versionSuffix}";
  # inherit (basePackages) kernel; # This one still has the updateScript
}
