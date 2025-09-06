{ edge, pkgs, ... }:
let
  xconfigDeps = with pkgs; [
    pkg-config
    bison
    flex
    gnumake
    stdenv.cc.cc

    qt6.qtbase
    qt6.qttools
  ];

  devishPrograms = with edge; [
    i2c-tools
  ];

in
{
  environment.systemPackages = xconfigDeps ++ devishPrograms;
}
