{ ... }: {

  swapDevices = [
    {
      label = "Swap";
      options = [ "discard" ];
    }
  ];

  # https://linuxblog.io/zswap-better-than-zram
  boot.zswap = {
    enable = true;
    maxPoolPercent = 20;
    compressor = "842"; # TODO: test, maybe zstd/lzo
    # acceptThresholdPercent = 90; # hysteresis :eyes:
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 50;
  };

  # https://kernel-internals.org/power/suspend
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
    # Only start counting the delay after unplugging
    HibernateOnACPower = false;

    AllowHibernation = true;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = true;
  };
}
