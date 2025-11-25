{
  custom,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelParams = [
    # TODO: slower on Zen 4?
    # "mitigations=off"
    "nowatchdog"
    # Disable SSD power-saving for lower latency
    # "nvme_core.default_ps_max_latency_us=0"
    "iommu.passthrough=1" # TODO: Default?
    "iommu=pt" # TODO: ^^^

    # "earlyprintk=vga"
  ];
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

  # LogLevel = "debug"
  # LogColor = "yes"
  # LogLocation = "yes"
  # LogTarget = "yes"
  # LogTime = "yes"
  # ShowStatus = "yes"
  systemd.settings.Manager = {
    #> Remove S from `less` to enable word-wrap
    Less = "FRXMK";
    #> Show unit names not just descriptions
    StatusUnitFormat = "combined";
  };

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
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$qziosG8H1ZEuu7FMixgtk0$4aTF5xoTyg1MzcH2yUcb1/L21w3IigoYdId.vEdLnA9";
  };
  users.mutableUsers = false;

  # Download more RAM!
  zramSwap = {
    enable = true;
    priority = 150;
    memoryPercent = 100;
  };

  # security.doas.enable = true;
  # security.sudo.enable = false;
  security.sudo.wheelNeedsPassword = false;

  # environment.etc."doas.conf".text = lib.mkForce ''
  #   permit nopass nolog keepenv root :wheel
  # '';
  # security.pam.services

  # security.polkit.debug = true;
  security.polkit.extraConfig = lib.mkForce ''
    polkit.addRule(function(action, subject) {
      // polkit.log(action);
      // polkit.log(subject);

      if (subject.local && subject.active && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      } else {
        // polkit.log("kinda sus");
      }
    });
  '';

  # TODO move
  # boot.kernel.sysctl = {
  # 	"centisex"
  # };
}
