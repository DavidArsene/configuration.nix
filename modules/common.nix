{
  config,
  lib,
  pkgs,
  ...
}:
{
  # enable minimal.nix
  nixos.minify.everything = true;

  boot = {
    # Use latest kernel by default instead of LTS
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
      configurationLimit = 6;
      editor = false;

      # includes UEFI shell
      netbootxyz.enable = true;
    };

    # Use persistent hardware ID for systemd's machine-id
    kernelParams = [ "system.machine_id=firmware" ];

    consoleLogLevel = 7;
  };

  # LogColor = "yes"
  # LogLocation = "yes"
  # LogTarget = "yes"
  # LogTime = "yes"
  # ShowStatus = "yes"
  systemd.settings.Manager = {
    #> Also show unit names, not just descriptions
    StatusUnitFormat = "combined";
    # When shutting down
    DefaultTimeoutStopSec = "10s";

    LogLevel = "debug";
    # ???
    # DefaultRestartMode = "debug";
    # RuntimeWatchdogSec = 0; ?
    # CtrlAltDelBurstAction = "poweroff-force";
  };
  systemd.ctrlAltDelUnit = "shutdown.target";

  time.timeZone = "Europe/Bucharest";

  i18n.extraLocaleSettings = {
    LANG = "ro_RO.UTF-8";
    # LANGUAGE = "en_US:en";
    LC_MESSAGES = "en_US.UTF-8";
  };

  users.users.${config.users.myself} = {
    isNormalUser = true;
    description = "David";
    # `input` required by GD CBF
    extraGroups = [
      "wheel"
      "input"
      "video" # FIXME test
      # "wireshark"
    ];
    hashedPassword = "$y$j9T$qziosG8H1ZEuu7FMixgtk0$4aTF5xoTyg1MzcH2yUcb1/L21w3IigoYdId.vEdLnA9";
  };
  users.mutableUsers = false;

  system.switch.inhibitors = {
    # Overly cautious reminder to reboot when upgrading nixpkgs
    davids-reboot-for-major-upgrades = lib.version;
  };

  # Download more RAM!
  zramSwap = {
    # TODO: enable for non-swap users
    # FIXME: conflicts with tmp.useZram
    enable = !config.boot.zswap.enable;
    priority = 150;
    memoryPercent = 100;
  };

  services = {
    # NOTE: fragile?
    # TODO: minimal?
    getty.enable = false;
    kmscon.enable = true;
    kmscon.config = {
      libseat = false;
      term = "xterm-256color";
    };
    #  systemd.services."kmsconvt@tty3" = {
    #    ExecStart = config.systemd.services."kmsconvt@".ExecStart;
    #  };
    # services.xserver.xkb.

    nohang.enable = true;
    # TODO nohang.configPath = ./my-nohang-config.conf;

    #* NOTE: udisks2.conf is merged from udisks2 module
    udisks2.settings."mount_options.conf" = {

      #! NOTE: Only applies to mounts handled by udisks2! (i.e, not in fstab)

      # https://storaged.org/udisks/docs/mount_options.html
      defaults = {
        # allow=exec,noexec,nodev,nosuid,atime,noatime,nodiratime,relatime,strictatime,lazytime,ro,rw,sync,dirsync,noload,acl,nosymfollow
        defaults = "noatime,noacl,discard=async"; # lazytime? async?

        # vfat_allow=uid=$UID,gid=$GID,flush,utf8,shortname,umask,dmask,fmask,codepage,iocharset,usefree,showexec
        vfat_defaults = "utf8=1,showexec,flush,umask=0077"; # TODO: restore uid=$UID,gid=$GID, ?

        # the two drivers identified as "ntfs:" and "ntfs3:"
        # ntfs:ntfs_allow=uid=$UID,gid=$GID,umask,dmask,fmask,locale,norecover,ignore_case,windows_names,compression,nocompression,big_writes
        "ntfs:ntfs_defaults" = "uid=$UID,gid=$GID,windows_names,discard,symlink=native,show_sys_files";
        ntfs_drivers = "ntfs"; # ,ntfs3

        # btrfs_allow=compress,compress-force,datacow,nodatacow,datasum,nodatasum,autodefrag,noautodefrag,degraded,device,discard,nodiscard,subvol,subvolid,space_cache
        btrfs_defaults = "compress=zstd:3";

        # ext4_allow=errors=remount-ro,commit*/
        ext4_defaults = "errors=remount-ro,commit=30";
      };
    };
  };

  security = {
    # systemd's builtin sudo
    run0 = {
      enable = true;
      wheelNeedsPassword = false;
      sudo-shim.enable = true;
    };
    sudo.enable = false;

    # pam.services

    # Enable polkit.log messages (removes "--no-debug")
    polkit.extraArgs = [ "--log-level=notice" ];

    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {

        if (action.id == "org.kde.powerdevil.backlighthelper.setbrightness")
        {
          // KDE spams this action for every keypress
          return polkit.Result.YES;
        }

        if (subject.local && subject.active && subject.isInGroup("wheel"))
        {
          polkit.log("Transparent authorization for pid=" + subject.pid + " user=" + subject.user + " action=" + action.id);
          return polkit.Result.YES;
        }
        polkit.log("Continuing regular authorization for pid=" + subject.pid + " user=" + subject.user + " action=" + action.id);
      });
    '';
  };
}
