{
  custom,
  lib,
  pkgs,
  ...
}:
{
  # enable minimal.nix
  nixos.minify.everything = true;

  boot.kernelParams = [
    # TODO: slower on Zen 4?
    "mitigations=off"
    "nowatchdog"
    # Disable SSD power-saving for lower latency
    # "nvme_core.default_ps_max_latency_us=0"

    # "earlyprintk=vga"
  ];

  # Use latest kernel by default instead of LTS
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

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
    DefaultTimeoutStopSec = "30s";

    # TODO: minimal mentioned?
    DefaultMemoryAccounting = false;
    DefaultTasksAccounting = false;
    DefaultIOAccounting = false;
    DefaultIPAccounting = false;

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

  users.users.${custom.myself} = {
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

  services.nohang.enable = true;
  # services.nohang.configPath = ./my-nohang-config.conf;

  security = {
    doas.enable = true;
    # sudo.enable = false;
    sudo.wheelNeedsPassword = false;

    # environment.etc."doas.conf".text = lib.mkForce ''
    #   permit nopass nolog keepenv root :wheel
    # '';
    # pam.services

    # Enable polkit.log messages (no "--no-debug")
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

  # TODO move
  # boot.kernel.sysctl = {
  # 	"centisex"
  # };
}
