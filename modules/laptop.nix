{ pkgs, ... }: {

  boot = {
    loader.efi.canTouchEfiVariables = true;

    # use NTFSPLUS
    blacklistedKernelModules = [ "ntfs3" ];
  };

  hardware = {
    usbStorage.manageShutdown = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        # https://github.com/bluez/bluez/blob/master/src/main.conf
        General = {
          Experimental = true;
          Testing = true;
          KernelExperimental = true;
        };
      };
    };

  };
  powerManagement = {
    enable = true;
    # bootCommands = "${pkgs.networkmanager}/bin/nmcli radio wifi on";
    # scsiLinkPolicy = "med_power_with_dipm"; # TODO: what?
  };

  #* Mostly from nixos-hardware
  services = {
    #? Desktop environments use the D-Bus interface provided by PPD.
    #? The alternatives are TLP and tuned, which expose a compatible
    #? interface via ".tlp.pd" and ".tuned.ppdSupport" respectively.
    power-profiles-daemon.enable = false;
    # auto-cpufreq.enable = false;

    tlp = {
      enable = false;
      pd.enable = true;
      settings = {
        TLP_DISABLE_DEFAULTS = 1;
        TLP_AUTO_SWITCH = 1; # always switch
        # TLP_PROFILE_DEFAULT = "SAV";
        TLP_PROFILE_AC = "BAL";
        TLP_PROFILE_BAT = "SAV";

        SOUND_POWER_SAVE_ON_BAT = 5;
        SOUND_POWER_SAVE_CONTROLLER = "Y";

        # START_CHARGE_THRESH_BAT0 = 0; # dummy value for Lenovo
        # STOP_CHARGE_THRESH_BAT0 = 1; # means enable for Lenovo

        AHCI_RUNTIME_PM_ON_BAT = "auto";

        MAX_LOST_WORK_SECS_ON_BAT = 30;

        RADEON_DPM_PERF_LEVEL_ON_SAV = "auto";
        AMDGPU_ABM_LEVEL_ON_BAT = 0;
        AMDGPU_ABM_LEVEL_ON_SAV = 3;

        NMI_WATCHDOG = 0;

        # WIFI_PWR_ON_AC = "off";
        # WIFI_PWR_ON_BAT = "on";

        WOL_DISABLE = "Y";

        PLATFORM_PROFILE_ON_BAT = "balanced";
        PLATFORM_PROFILE_ON_SAV = "low-power";

        SATA_LINKPWR = "med_power_with_dipm";
        USB_BLACKLIST_PHONE = 1;
      };
    };

    tuned = {
      enable = true;
      # https://github.com/redhat-performance/tuned/blob/master/tuned-main.conf
      settings = {
        # daemon = true;
        # dynamic_tuning = false;
        sleep_interval = 10;
        update_interval = 20;
        recommend_command = false;
      };

      ppdSupport = true;
      # https://github.com/redhat-performance/tuned/blob/master/tuned/ppd/ppd.conf
      #      ppdSettings = {
      #        main = {
      #          default = "balanced";
      #          battery_detection = true;
      #          # sysfs_acpi_monitor = true;
      #        };
      #        profiles = {
      #          power-saver = "powersave";
      #          balanced = "balanced";
      #          performance = "balanced";
      #        };
      #        battery = {
      #          power-saver = "powersave";
      #          balanced = "balanced";
      #        };
      #      };
    };

    fstrim.enable = true; # TODO: discard?

    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
    };

    ananicy = {
      # enable = true;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
  };
}
