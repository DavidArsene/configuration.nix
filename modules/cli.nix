{ edge, ... }:
{

  environment.etc."ncdu.conf".text = ''
    --extended
    --exclude-kernfs
    --threads 4
    --show-itemcount
    --show-mtime
    --graph-style eighth-block
    --shared-column unique
    --color dark
  '';

  environment.systemPackages = with edge; [
    broot
    micro # nano
    ncdu
    superfile
  ];
}
