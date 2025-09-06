{ config, nixos-rebuild-ng }:
(nixos-rebuild-ng.override {

  nix = config.nix.package;
  withNgSuffix = false;
  withReexec = true;
  withTmpdir = "/tmp";

}).overridePythonAttrs
  (_: {
    patches = [
      ./better-error-handling.patch
    ];
  })
