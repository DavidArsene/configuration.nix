{
  custom,
  spicetify,
  newpkgs,
  ...
}:
let
  spicePkgs = spicetify.legacyPackages.${custom.system};

  spicedSpotify = spicetify.lib.mkSpicetify newpkgs {
    enabledExtensions = with spicePkgs.extensions; [
      autoSkipVideo
      popupLyrics
      shuffle
      powerBar
      seekSong
      playlistIcons
      fullAlbumDate
      listPlaylistsWithSong
      playlistIntersection
      phraseToPlaylist
      wikify
      writeify
      songStats
      betterGenres
      playNext
      sectionMarker
      beautifulLyrics
      aiBandBlocker
    ];

    theme = spicePkgs.themes.text;

    alwaysEnableDevTools = true;
    experimentalFeatures = true;
  };
in

{
  environment.systemPackages = [ spicedSpotify ];
}
