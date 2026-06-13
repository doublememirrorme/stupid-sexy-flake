{ config, lib, pkgs, ... }:
let
  home = config.home.homeDirectory;
  secretsFile = "${home}/.config/nix-darwin/secrets/beets.env";
  beetsSecretsYaml = "${home}/.config/beets/secrets.yaml";

  writeBeetsSecrets = pkgs.writeShellScript "write-beets-secrets" ''
    set -eu
    secretsFile="${secretsFile}"
    outFile="${beetsSecretsYaml}"

    if [ ! -f "$secretsFile" ]; then
      echo "warning: $secretsFile not found; copy secrets/beets.env.example and add your Discogs token" >&2
      exit 0
    fi

    set -a
    # shellcheck disable=SC1090
    . "$secretsFile"
    set +a

    if [ -z "''${DISCOGS_USER_TOKEN:-}" ]; then
      echo "warning: DISCOGS_USER_TOKEN is empty in $secretsFile" >&2
      exit 0
    fi

    mkdir -p "$(dirname "$outFile")"
    ${pkgs.python3}/bin/python3 -c '
import json
import sys

token = sys.argv[1]
print("discogs:")
print("  user_token:", json.dumps(token))
' "$DISCOGS_USER_TOKEN" > "$outFile"
    chmod 600 "$outFile"
  '';
in
{
  programs.beets = {
    enable = true;

    settings = {
      include = [ "secrets.yaml" ];

      directory = "${home}/Music/Library/";
      library = "${home}/Library/Application Support/beets/library.db";

      import = {
        move = true;
        copy = false;
        write = true;
        art = true;
      };

      paths = {
        default = ''Albums/$albumartist/$album%aunique{}/$track - $title'';
        comp = ''Compilations/$album%aunique{}/$track - $artist - $title'';
        singleton = ''Singles/$artist/$track - $title'';
        "albumtype:mix" = ''Mixes/$album%aunique{}/$track - $title'';
      };

      plugins = [
        "chroma"
        "discogs"
        "musicbrainz"
        "autobpm"
        "fetchart"
        "embedart"
        "keyfinder"
        "lastgenre"
        "mbsync"
        "info"
        "zero"
        "web"
      ];

      discogs = {
        data_source_mismatch_penalty = 0.0;
        index_tracks = true;
        append_style_genre = true;
      };

      musicbrainz = {
        data_source_mismatch_penalty = 0.5;
      };

      keyfinder = {
        auto = false;
        bin = "${pkgs.keyfinder-cli}/bin/keyfinder-cli";
      };

      lastgenre = {
        auto = true;
        count = 3;
        force = false;
        keep_existing = true;
        canonical = true;
        prefer_specific = true;
        min_weight = 15;
        source = "album";
      };

      fetchart = {
        auto = true;
        cautious = true;
        maxwidth = 1200;
        enforce_ratio = false;
        sources = "coverart itunes amazon albumart filesystem";
      };

      embedart = {
        auto = true;
        remove_art_file = false;
      };

      chroma = {
        auto = false;
      };

      autobpm = {
        auto = false;
      };

      zero = {
        fields = [
          "comments"
          "artist_sort"
          "artists"
          "artists_sort"
          "artists_credit"
          "albumartist_sort"
          "albumartists"
          "albumartists_sort"
          "albumartists_credit"
          "album_artist"
          "album_artists"
          "album_artists_credit"
          "artist_credit"
          "Album Artist Credit"
          "ARTISTS"
          "ARTISTS_SORT"
          "ARTISTS_CREDIT"
          "TOPE"
          "publisher"
          "comment"
        ];
        update_database = false;
      };

      web = {
        host = "127.0.0.1";
        port = 8337;
        readonly = true;
      };
    };
  };

  home.packages = [
    pkgs.chromaprint
    pkgs.keyfinder-cli
  ];

  home.activation.writeBeetsSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${writeBeetsSecrets}
  '';
}
