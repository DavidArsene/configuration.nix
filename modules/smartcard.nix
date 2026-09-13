{
  pkgs,
  ...
}:
{
  services.pcscd = {
    enable = true;
    extraArgs = [
      "--info"
      "--reader-name-no-serial"
      "--reader-name-no-interface"
    ];
  };

  # security.pam.p11.enable = true;
  # security.pam.p11.control = "sufficient";

  environment.systemPackages = with pkgs; [
    nss_latest.tools # modutil
    opensc
    pcsc-tools # pcsc_scan
  ];

  services.neard.enable = true;
}
