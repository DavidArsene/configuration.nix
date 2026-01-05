{
  custom,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelParams = [
    # TODO: slower on Zen 4?
    "mitigations=off"
    "nowatchdog"
    # Disable SSD power-saving for lower latency
    # "nvme_core.default_ps_max_latency_us=0"
    "iommu.passthrough=1" # TODO: Default?
    "iommu=pt" # TODO: ^^^

    # "earlyprintk=vga"
  ];
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

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "C.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "C.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "C.UTF-8";
  };
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "en_US/ISO-8859-1"
    "ro_RO.UTF-8/UTF-8"
    "ro_RO/ISO-8859-2"
  ];

  users.users.${custom.myself} = {
    isNormalUser = true;
    description = "David";
    # `input` required by CBF
    extraGroups = [
      "wheel"
      "input"
    ];
    hashedPassword = "$y$j9T$qziosG8H1ZEuu7FMixgtk0$4aTF5xoTyg1MzcH2yUcb1/L21w3IigoYdId.vEdLnA9";
  };
  users.mutableUsers = false;

  # Download more RAM!
  zramSwap = {
    enable = true;
    priority = 150;
    memoryPercent = 100;
  };

  security.doas.enable = true;
  # security.sudo.enable = false;
  security.sudo.wheelNeedsPassword = false;

  # environment.etc."doas.conf".text = lib.mkForce ''
  #   permit nopass nolog keepenv root :wheel
  # '';
  # security.pam.services

  security.polkit.debug = true;
  security.polkit.extraConfig = ''

    polkit.addRule(function(action, subject) {
      polkit.log( action.toString());
      polkit.log(subject.toString());

      if (subject.local && subject.active && subject.isInGroup("wheel"))
      {
        polkit.log("trivial: Authorized!");
        return polkit.Result.YES;
      }

      polkit.log("trivial: Not Handled.");
    });
  '';

  # TODO move
  # boot.kernel.sysctl = {
  # 	"centisex"
  # };
}
