{ }: {

  services.tuned.settings.profiles.powersavermu = {

    plugins = {

      acpi = {
        platform_profile = "powersave";
      };
      audio = { };
      bootloader = { };
      cpu = {
        # load_threshold = "0.2";
        # latency_low = "100";
        # latency_high = "1000";
        # force_latency = "None";

        # cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_governors
        # cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        governor = "powersave";
        # sampling_down_factor = "None"; TODO:
        energy_perf_bias = "powersave"; # FIXME: values
        # min_perf_pct = "None";
        # max_perf_pct = "None";
        # no_turbo = "None";
        # pm_qos_resume_latency_us = "None";

        # cat /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_available_preferences
        energy_performance_preference = "balance_power|power";
        # boost = true;
      };
      disk = { }; # TODO: any use for SSDs?
      irq = { }; # finertuned control than `scheduler`
      irqbalance = { };
      modules = { };
      mounts = {
        # disable_barriers=false;
      };
      net = {
        # dynamic = true;
        # wake_on_lan = "None";
        # nf_conntrack_hashsize = "None";
        # features = "None";
        # coalesce = "None";
        # pause = "None";
        # ring = "None";
        # channels = "None";
        # txqueuelen = "None";
        # mtu = "None";
      };
      # rtentsk = { };
      scheduler = { }; # TODO:
      script = { }; # last resort
      scsi_host = {
        alpm = "TODO";
      };
      service = { };
      sysctl = { }; # if no other plugin available
      # TODO: research /sys/devices/system/machinecheck/machinecheck*/ignore_ce=1
      sysfs = { }; # same
      systemd = {
        # cpu_affinity=""; # FIXME: only this?
      };
      usb = {
        devices = "1-5"; # internal keybooard (for me)
        autosuspend = 0;
      };
      video = {
        # default, auto, low, mid, high, dynpm, dpm-battery, dpm-balanced, dpm-perfomance
        radeon_powersave = "dpm-battery";
        panel_power_savings = 3;
      };
      vm = {
        transparent_hugepages = "None";
        transparent_hugepage = "None";
        "transparent_hugepage.defrag" = "None";
        dirty_bytes = "None";
        dirty_ratio = "None";
        dirty_background_bytes = "None";
        dirty_background_ratio = "None";
      };
    };
  };

}
