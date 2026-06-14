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

  beetDupAlbums = pkgs.writeShellScriptBin "beet-dup-albums" ''
    ${pkgs.python3}/bin/python3 <<'PY'
import os
import sqlite3
from collections import defaultdict

db = os.path.expanduser("~/Library/Application Support/beets/library.db")
con = sqlite3.connect(db)
con.row_factory = sqlite3.Row
norm = lambda s: (s or "").strip().casefold()

rows = con.execute("""
  SELECT a.albumartist, a.album, a.mb_albumid, COUNT(i.id) AS tracks, MIN(i.path) AS path
  FROM albums a LEFT JOIN items i ON i.album_id = a.id
  GROUP BY a.id ORDER BY a.album, a.albumartist
""").fetchall()

groups = defaultdict(list)
for row in rows:
    groups[(norm(row["albumartist"]), norm(row["album"]))].append(row)

for group in sorted(
    (g for g in groups.values() if len(g) > 1),
    key=lambda g: (g[0]["album"], g[0]["albumartist"]),
):
    print(f"{group[0]['albumartist']} | {group[0]['album']} | {len(group)} copies")
    for row in group:
        path = row["path"]
        if isinstance(path, bytes):
            path = path.decode()
        print(f"  {row['tracks']} tracks | mb={row['mb_albumid'] or '-'} | {os.path.dirname(path)}")
    print()
PY
  '';

  beetOrphans = pkgs.writeShellApplication {
    name = "beet-orphans";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      export musicLib="${home}/Music/Library"
      export beetsDb="${home}/Library/Application Support/beets/library.db"

      exec python3 - "$@" <<'PY'
import os
import shutil
import sqlite3
import sys

MUSIC_LIB = os.environ["musicLib"]
BEETS_DB = os.environ["beetsDb"]
AUDIO_EXT = {".flac", ".mp3", ".m4a", ".aac", ".ogg", ".opus", ".wav", ".aiff", ".aif"}

delete = "--delete" in sys.argv
force = "--force" in sys.argv
show_partial = "--partial" in sys.argv or not delete


def ps(path):
    return path.decode() if isinstance(path, bytes) else path


def audio_files(directory):
    try:
        names = os.listdir(directory)
    except OSError:
        return []
    return [
        name
        for name in names
        if os.path.splitext(name)[1].lower() in AUDIO_EXT
        and os.path.isfile(os.path.join(directory, name))
    ]


def album_dirs():
    dirs = []
    for root in ("Albums", "Compilations", "Mixes"):
        base = os.path.join(MUSIC_LIB, root)
        if not os.path.isdir(base):
            continue
        for artist in sorted(os.listdir(base)):
            artist_path = os.path.join(base, artist)
            if not os.path.isdir(artist_path):
                continue
            for album in sorted(os.listdir(artist_path)):
                album_path = os.path.join(artist_path, album)
                if os.path.isdir(album_path):
                    rel = f"{root}/{artist}/{album}"
                    dirs.append((rel, album_path))
    return dirs


if not os.path.isfile(BEETS_DB):
    print(f"error: beets library not found at {BEETS_DB}", file=sys.stderr)
    sys.exit(1)

con = sqlite3.connect(BEETS_DB)
beets_files = {ps(row[0]) for row in con.execute("SELECT path FROM items")}
con.close()

orphans = []
partials = []

for rel, album_path in album_dirs():
    files = audio_files(album_path)
    if not files:
        continue
    tracked = [name for name in files if os.path.join(album_path, name) in beets_files]
    untracked = [name for name in files if os.path.join(album_path, name) not in beets_files]
    if not tracked:
        orphans.append((rel, album_path, files))
    elif untracked:
        partials.append((rel, album_path, untracked, files))

print(f"Music library: {MUSIC_LIB}")
print(f"Tracked files in beets: {len(beets_files)}\n")

print(f"Fully orphan album folders: {len(orphans)}")
print("=" * 64)
if orphans:
    for rel, album_path, files in orphans:
        print(f"  {rel} ({len(files)} audio, 0 in beets)")
else:
    print("  none")

if show_partial:
    print(f"\nPartially untracked album folders: {len(partials)}")
    print("=" * 64)
    if partials:
        for rel, album_path, untracked, files in partials:
            print(f"  {rel} ({len(untracked)}/{len(files)} untracked)")
            for name in untracked[:5]:
                print(f"    - {name}")
            if len(untracked) > 5:
                print(f"    ... +{len(untracked) - 5} more")
    else:
        print("  none")

if not delete:
    if orphans:
        print("\nTo remove fully orphan folders:")
        print("  beet-orphans --delete")
    sys.exit(0)

if not orphans:
    print("\nNothing to delete.")
    sys.exit(0)

print("\nWill delete fully orphan folders only (partial folders are skipped).")
for rel, album_path, files in orphans:
    print(f"  rm -rf {album_path}")

if not force:
    if not sys.stdin.isatty():
        print(
            "\nNon-interactive shell: use --force to delete without prompting.",
            file=sys.stderr,
        )
        sys.exit(1)
    try:
        answer = input("\nDelete these folders? [y/N] ").strip().casefold()
    except EOFError:
        print("\nCancelled (no input). Use --force to delete without prompting.")
        sys.exit(1)
    if answer not in ("y", "yes"):
        print("Cancelled.")
        sys.exit(0)

for rel, album_path, files in orphans:
    shutil.rmtree(album_path)
    print(f"deleted {rel}")

print(f"\nDeleted {len(orphans)} folder(s).")
PY
    '';
  };
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
        "duplicates"
        "zero"
        "web"
      ];

      duplicates = {
        keys = [
          "albumartist"
          "album"
        ];
      };

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
        # MediaFile field names only (see `beet fields`); raw tag/frame names are rejected.
        fields = [
          "comments"
          "artist_sort"
          "artist_credit"
          "artists"
          "artists_sort"
          "artists_credit"
          "albumartist"
          "albumartist_sort"
          "albumartist_credit"
          "albumartists"
          "albumartists_sort"
          "albumartists_credit"
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
    beetDupAlbums
    beetOrphans
  ];

  home.activation.writeBeetsSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${writeBeetsSecrets}
  '';
}
