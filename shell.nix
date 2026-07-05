{ self, pkgs, ... }:
let
  kernel = pkgs.linux_latest;
in

pkgs.mkShell {

  buildInputs = with pkgs; [
    bison
    flex
    qt6.qtbase

    pkg-config
    perl
  ];

  shellHook = ''
    set -eu

    make() {
      echo "  MAKE $*"
      command make -j "$(nproc)" "$@"
    }

    checkpoint() {
      echo "Checkpoint: $1"
      echo

      make savedefconfig
      cp defconfig defconfig.$1

      [ -f defconfig.old ] && scripts/diffconfig defconfig.old defconfig | tee change.$1.txt

      mv defconfig defconfig.old
      echo
    }

    mkdir -p /tmp/xconfig
    cd /tmp/xconfig || exit 1

    if [ ! -f Makefile ]; then
      echo "new source"
      tar -xf "${kernel.src}" --strip-components=1
    fi

    if [ ! -f ".config" ]; then
      echo "new config"
      cp "${kernel.configfile}" .config

      checkpoint "orig"
    fi

    cat ${self + /hosts/legionix/modprobed-db.txt} | rg -v -e '#' -e '^$' | uniq > lsmod.txt

    LSMOD=lsmod.txt make localmodconfig
    checkpoint "lsmod"

    for (( i = 1; ; i++ )); do
      make xconfig
      checkpoint "xconfig_$i"
      read -p "Continue?"
    done

    exit
  '';
}
