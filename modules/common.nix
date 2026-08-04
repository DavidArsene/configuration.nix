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
  };

  # LogLevel = "debug"
  # LogColor = "yes"
  # LogLocation = "yes"
  # LogTarget = "yes"
  # LogTime = "yes"
  # ShowStatus = "yes"
  systemd.settings.Manager = {
    #> Remove S from `less` to enable word-wrap
    #! FIXME: conflicts with systemd.nix because string without priority
    # ManagerEnvironment = "LESS=FRXMK";
    #> Show unit names not just descriptions
    StatusUnitFormat = "combined";
    # When shutting down
    DefaultTimeoutStopSec = "10s";

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
    enable = false; # FIXME: conflicts with tmp.useZram
    priority = 150;
    memoryPercent = 100;
  };

  # NOTE: udisks2.conf is merged from udisks2 module
  # FIXME: comment
  comment.services.udisks2.settings."mount_options.conf" = {

    # https://storaged.org/udisks/docs/mount_options.html
    defaults = {
      # allow=exec,noexec,nodev,nosuid,atime,noatime,nodiratime,relatime,strictatime,lazytime,ro,rw,sync,dirsync,noload,acl,nosymfollow
      defaults = "noatime"; # lazytime? async? noacl? DISCARD?

      # vfat_allow=uid=$UID,gid=$GID,flush,utf8,shortname,umask,dmask,fmask,codepage,iocharset,usefree,showexec
      vfat_defaults = "utf8=1,showexec,flush,umask=0077"; # TODO: restore uid=$UID,gid=$GID, ?

      # common options for both the native kernel driver and exfat-fuse
      # exfat_allow=uid=$UID,gid=$GID,dmask,errors,fmask,iocharset,namecase,umask
      # exfat_defaults = "uid=$UID,gid=$GID,iocharset=utf8,errors=remount-ro";

      # 'ntfs' signature, definitions for the legacy ntfs kernel driver and the ntfs-3g fuse driver
      # ntfs:ntfs_allow=uid=$UID,gid=$GID,umask,dmask,fmask,locale,norecover,ignore_case,windows_names,compression,nocompression,big_writes
      "ntfs:ntfs_defaults" = "uid=$UID,gid=$GID,windows_names,discard,symlink=native,show_sys_files";

      # define order of filesystem driver priorities for the actual mount call,
      # required definition for non-matching driver names
      ntfs_drivers = "ntfs"; # ,ntfs3";

      # iso9660_allow=uid=$UID,gid=$GID,norock,nojoliet,iocharset,mode,dmode,map,check
      # iso9660_defaults = "uid=$UID,gid=$GID,iocharset=utf8,mode=0400,dmode=0500";

      # btrfs_allow=compress,compress-force,datacow,nodatacow,datasum,nodatasum,autodefrag,noautodefrag,degraded,device,discard,nodiscard,subvol,subvolid,space_cache

      # f2fs_allow=discard,nodiscard,compress_algorithm,compress_log_size,compress_extension,compress_chksum,alloc_mode,atgc,gc_merge,nogc_merge

      # xfs_allow=discard,nodiscard,inode32,largeio,wsync

      # reiserfs_allow=hashed_relocation,no_unhashed_relocation,noborder,notail

      # ext4_allow=errors=remount-ro,commit*/
      # ext4_defaults = "errors=remount-ro";
    };
  };

  # NOTE: fragile?
  # TODO: minimal?
  services.getty.enable = false;
  services.kmscon = {
    enable = true;
    config = {
      libseat = false;
      term = "xterm-256color";
    };
  };
  #  systemd.services."kmsconvt@tty3" = {
  #    ExecStart = config.systemd.services."kmsconvt@".ExecStart;
  #  };
  # services.xserver.xkb.

  services.nohang.enable = true;
  # TODO services.nohang.configPath = ./my-nohang-config.conf;

  security = {
    # systemd's builtin sudo
    run0 = {
      enable = true;
      wheelNeedsPassword = false;
      sudo-shim.enable = true;
    };
    sudo.enable = false;
    sudo.wheelNeedsPassword = false;

    # account-utils.enable = true;

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

        polkit.log("Privilege request:  pid=" + subject.pid + " user=" + subject.user + " action=" + action.id);
        // polkit.log(action.toString());
        // polkit.log(subject.toString());

        if (subject.local && subject.active && subject.isInGroup("wheel"))
        {
          polkit.log("Authorized quickly.");
          return polkit.Result.YES;
        }
        polkit.log("Continuing regular authorization.");
      });
    '';
  };
}
