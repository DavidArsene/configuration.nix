{
  fetchFromGitHub,
  fetchurl,
  lib,
  stdenv,
  kernel,
  # ogKernelConfigfile,
  versions,
}:
let
  inherit (versions.linux) version;
  majorMinor = lib.versions.majorMinor version;

  patches-src = fetchFromGitHub {
    owner = "CachyOS";
    repo = "kernel-patches";
    inherit (versions.patches) rev hash;
  };

  config-src = fetchFromGitHub {
    owner = "CachyOS";
    repo = "linux-cachyos";
    inherit (versions.config) rev hash;
  };

  src = fetchurl {
    url = "https://git.kernel.org/torvalds/t/linux-${version}.tar.gz";
    inherit (versions.linux) hash;
  };

  patches = [ "${patches-src}/${majorMinor}/all/0001-cachyos-base-all.patch" ];

  pkgbuildCompact = [
    "-e CACHY"
    "-d GENERIC_CPU"
    "-e MZEN4"
    "-d X86_NATIVE_CPU"

    # changed by chaotic-nyx but I don't like it
    # "-d CPU_FREQ_DEFAULT_GOV_SCHEDUTIL"
    # "-e CPU_FREQ_DEFAULT_GOV_PERFORMANCE"

    # PKGBUILD defaults ported by chaotic-nyx
    # ---------------------------------------
    # _nr_cpus, defaults to empty, which later set this
    "--set-val NR_CPUS 320"

    # _tcp_bbr3, defaults to "y"
    "-m TCP_CONG_CUBIC"
    "-d DEFAULT_CUBIC"
    "-e TCP_CONG_BBR"
    "-e DEFAULT_BBR"
    "--set-str DEFAULT_TCP_CONG bbr"
    "-m NET_SCH_FQ_CODEL"
    "-e NET_SCH_FQ"
    "-d DEFAULT_FQ_CODEL"
    "-e DEFAULT_FQ"
    "--set-str DEFAULT_NET_SCH fq"

    # Nixpkgs don't support this
    "-d CONFIG_SECURITY_TOMOYO"
    # ---------------------------------------

    # Nyx defaults 2
    # _cc_harder, defaults to "y"
    "-d CC_OPTIMIZE_FOR_PERFORMANCE"
    "-e CC_OPTIMIZE_FOR_PERFORMANCE_O3"

    # _lru_config, defaults to "standard"
    "-e LRU_GEN"
    "-e LRU_GEN_ENABLED"
    "-d LRU_GEN_STATS"

    # _vma_config, defaults to "standard"
    "-e PER_VMA_LOCK"
    "-d PER_VMA_LOCK_STATS"
    # --------------

    # -----------------------------
    # Included for replacing initrd
    "-e NVME_KEYRING"
    "-e NVME_AUTH"
    "-e NVME_CORE"
    "-e BLK_DEV_NVME"
    "-d NVME_TARGET"
    # -----------------------------

    # maybe test madvise
    "-d TRANSPARENT_HUGEPAGE_MADVISE"
    "-e TRANSPARENT_HUGEPAGE_ALWAYS"

    # responsiveness?
    "-e HZ_300"
    # "--set-val HZ ${toString cachyConfig.ticksHz}"
    # "-e HZ_${toString cachyConfig.ticksHz}"

    # tickrate full
    "-d HZ_PERIODIC"
    "-d NO_HZ_IDLE"
    "-e NO_HZ_FULL"
    "-e NO_HZ_FULL_NODEF"
    "-e NO_HZ"
    "-e NO_HZ_COMMON"
    "-d CONTEXT_TRACKING_FORCE"
    "-e CONTEXT_TRACKING"

    # full preempt = more checks, better latency
    # lazy preempt = less checks, better throughput
    # nyx variant
    # "-e PREEMPT"
    # "-e PREEMPT_BUILD"
    # "-d PREEMPT_NONE"
    # "-d PREEMPT_VOLUNTARY"
    # "-e PREEMPT_COUNT"
    # "-e PREEMPTION"
    # "-e PREEMPT_DYNAMIC"
    "-d PREEMPT"
    "-d PREEMPT_NONE"
    "-d PREEMPT_VOLUNTARY"
    "-e PREEMPT_LAZY"
    "-e PREEMPT_DYNAMIC"

    # wine hardware sync
    "-m NTSYNC"
    # HDR
    "-e AMD_PRIVATE_COLOR"

    "-d DEBUG_INFO"
    "-d DEBUG_INFO_BTF"
    "-d DEBUG_INFO_DWARF4"
    "-d DEBUG_INFO_DWARF5"
    "-d PAHOLE_HAS_SPLIT_BTF"
    "-d DEBUG_INFO_BTF_MODULES"
    "-d SLUB_DEBUG"
    "-d PM_DEBUG"
    "-d PM_ADVANCED_DEBUG"
    "-d PM_SLEEP_DEBUG"
    "-d ACPI_DEBUG"
    "-d SCHED_DEBUG"
    "-d LATENCYTOP"
    "-d DEBUG_PREEMPT"
  ];

  customModuleList = ./modprobed.db;

in
stdenv.mkDerivation (finalAttrs: {
  inherit src patches;

  # ??
  # inherit (ogKernelConfigfile) meta;

  name = "linux-cachyos";
  nativeBuildInputs = kernel.nativeBuildInputs ++ kernel.buildInputs;
  # ++ (with pkgs.kdePackages; [
  #   qtbase
  #   wrapQtAppsHook
  #   pkgs.u-config
  # ]);

  postPhase = ''
    ${finalAttrs.passthru.extraVerPatch}
  '';

  buildPhase = ''
    runHook preBuild

    cp "${config-src}/linux-cachyos-rc/config" ".config"

    # TODO: CUSTOM @David
    #old make flags: CC=clang LD=ld.lld LLVM=1 LLVM_IAS=1
    make LSMOD="${customModuleList}" localmodconfig

    # Ooh interactive
    # make xconfig
    # TODO: fix qt6

    make olddefconfig
    patchShebangs scripts/config
    scripts/config ${lib.concatStringsSep " " pkgbuildCompact}
    make olddefconfig

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp .config $out

    runHook postInstall
  '';

  passthru = {
    inherit versions stdenv;
    kernelPatches = patches;
    extraVerPatch = ''
      sed -Ei"" 's/EXTRAVERSION = ?(.*)$/EXTRAVERSION = \1${versions.suffix}/g' Makefile
    '';
  };
})
