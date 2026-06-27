{
  custom,
  spicetify,
  pkgs,
  ...
}:
let
  spicePkgs = spicetify.legacyPackages.${custom.system};

  spicedSpotify = spicetify.lib.mkSpicetify pkgs {

    # https://gerg-l.github.io/spicetify-nix/extensions.html
    enabledExtensions = with spicePkgs.extensions; [
      # autoSkipVideo
      popupLyrics
      # shuffle
      powerBar
      seekSong
      skipOrPlayLikedSongs
      playlistIcons
      fullAlbumDate
      listPlaylistsWithSong
      # wikify
      featureShuffle
      songStats
      autoVolume
      showQueueDuration
      betterGenres
      playNext
      playingSource
      sectionMarker
      beautifulLyrics
      aiBandBlocker
      sortPlay
      extendedCopy
      madeForYouShortcut
      # romajiConvert
      spicyLyrics
      ytVideo
    ];

    theme = spicePkgs.themes.dribbblishDynamic;

    alwaysEnableDevTools = true;
    experimentalFeatures = true;
  };
in

{
  environment.systemPackages = [ spicedSpotify ];
}
