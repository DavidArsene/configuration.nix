{ pkgs, ... }:
{
  # get current kernel without compiling and run make xconfig

  src = pkgs.fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    rev = "v6.8";
    hash = "sha256-+q3b0bq5h7mYk1b0n2e5c9f1v3y7z8x9a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5";
  };

  buildInputs = [
    pkgs.qt6.full
    pkgs.qt6.qttools
    pkgs.cmake
    pkgs.gcc
    pkgs.libcxx
  ];
  nativeBuildInputs = [ pkgs.wrapQtAppsHook pkgs.pkg-config ];
  patches = [ ./patches/0001-Fix-build-with-Qt-6.5.0.patch ];
  dontUseCmakeConfigure = true;
  makeFlags = [
    "CC=${pkgs.clang}/bin/clang"
    "LD=${pkgs.llvmPackages.lld}/bin/lld"
    "LLVM=1"
    "LLVM_IAS=1"
  ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r .config $out/bin/xconfig.config

    make INSTALL_HDR_PATH=$out/usr headers_install
    make INSTALL_MOD_PATH=$out modules_install

    mkdir -p $out/bin
    cp -r xconfig $out/bin/
    wrapQtApp $out/bin/xconfig

    runHook postInstall
  '';
  pname = "xconfig";
  version = "6.8-rc1";

  meta = {
    description = "QT6-based XConfig, a graphical kernel configuration tool";
    platforms = pkgs.lib.platforms.linux;
  };
}
