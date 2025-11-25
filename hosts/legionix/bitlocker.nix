{ pkgs, lib, ... }:
let

  partitions = {
    "C:" = "Windows";
    "D:" = "Data";
  }; # !
  idType = "partlabel";
  # TODO: use ntfsplus

  ntfsMountOptions = [
    "rw"
    "noatime" # relatime

    # sets noexec, nosuid, and nodev
    "users"
    "exec"

    # as set by udisks2
    "uid=1000"
    "gid=100"
    # "umask=007"
    # dmask=027, fmask=137 wat

    # ntfs3 specific
    "iocharset=utf8"
    # "nohidden" # hide files marked HIDDEN
    # "sys_immutable" # make SYSTEM files read-only
    # "hide_dot_files" # sync dotfiles with HIDDEN
    # "windows_names" # reject invalid Windows names
    "discard" # SSD TRIM
    # "sparse" # create new files as sparse
    "showmeta" # show hidden NTFS files
    # "prealloc" # decrease fragmentation
    # "acl" # not NTFS ACLs
  ];

  walletQuery = ''
    kwallet-query kdewallet --folder SolidLuks --read-password
  '';
in
with lib;
{
  systemd.services."bitocker-unlock" = {
    description = "Unlock BitLocker encrypted drives";
    after = [
      "systemd-udev-settle.service"
      "network.target"
    ];
    wantedBy = [ "graphical.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutStartSec = "0";

      Environment = "PATH=${
        with pkgs;
        makeBinPath [
          cryptsetup
          kdePackages.kwallet
          mountutils
        ]
      }";

      # the best i could do in terms of ridiculous lib functions
      ExecStart = concatMapAttrsStringsSep "\n" (mnt: id: ''

        cryptsetup open --type bitlk /dev/disk/by-${idType}/${id} ${id} \
          --key-file=<( ${walletQuery} ${id} ) --allow-discards --verbose
        #! always remember allow-discards for good ssd health ^

        cryptsetup status ${id}

        mount /dev/mapper/${id} /${mnt} -v -t ntfs3 \
          -o ${concatStringsSep "," ntfsMountOptions}

      '') partitions;
      ExecStop = concatMapAttrsStringsSep "\n" (mnt: id: ''

        umount -v /${mnt}
        cryptsetup close -v ${id}

      '') partitions;
    };
  };

  environment.etc."crypttab" = {
    enable = false;
    mode = "0600";
    text = ''
      # <volume-name> <encrypted-device> [key-file] [options]
      ... /dev/disk/by-partlabel/... key bitlk,discard
    '';
  };

  fileSystems = {
    "..." = {
      enable = false;
      device = "/dev/mapper/...";
      fsType = "ntfs3";
      options = ntfsMountOptions;
    };
  };

}
