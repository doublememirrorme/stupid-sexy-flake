{ pkgs, ... }:
let
  palette = import ./tinacious-palette.nix;
  tomlFormat = pkgs.formats.toml { };

  # Tinacious Light's accents are faint as text on its #f8f8ff background
  # (1.8 to 2.9:1), and yazi draws most of its text in them. The light flavor
  # uses darker shades of the same hues that reach about 5:1. The dark flavor,
  # iTerm2 and tmux keep the palette as it is. Pink stays palette.pink wherever
  # it is a badge background with white text.
  lightText = palette.light // {
    blue = "#006ca6";    # was #01a9e1
    yellow = "#9a5c00";  # was #FFAA00
    green = "#00803c";   # was #00b253
    cyan = "#007a7c";    # was palette.cyan #00CED1
    purple = "#9b3fd1";  # was palette.purple #CC66FF
    pink = palette.pinkDeep; # was palette.pink #ff3399, for text only
  };
  darkText = palette.dark // { inherit (palette) cyan purple pink; };

  # One flavor per Tinacious variant. yazi asks the terminal whether it is
  # light or dark (CSI ?996n, OSC 11) and re-picks on every change report
  # (mode 2031), which iTerm2 sends when its light/dark colours flip. So the
  # pair follows the system appearance with no daemon. Inside tmux (3.6+),
  # tmux answers those queries for iTerm2 and forwards the change reports.
  # A tmux session with no attached client gets no answer, so yazi falls back
  # to its built-in theme there. Key names are the yazi 26.x ones ([mgr],
  # [indicator]); the hovered row is [indicator].current.
  mkFlavor = variant:
    let
      onPink = { fg = palette.white; bg = palette.pink; };
      onPurple = { fg = palette.white; bg = palette.purple; };
      onPinkDeep = { fg = palette.white; bg = palette.pinkDeep; };
      subtle = { fg = variant.foreground; bg = variant.selection; };
      border = { fg = variant.border; };
      title = { fg = variant.pink; bold = true; };
    in
    {
      mgr = {
        cwd = { fg = variant.pink; bold = true; };
        find_keyword = { fg = variant.yellow; bg = "reset"; bold = true; italic = true; underline = true; };
        find_position = { fg = variant.purple; bg = "reset"; bold = true; italic = true; };
        # No fg: takes the row's colour, so it stays readable on the pink hovered row.
        symlink_target = { italic = true; };

        marker_copied = { fg = variant.green; bg = variant.green; };
        marker_cut = { fg = palette.pink; bg = palette.pink; };
        marker_marked = { fg = variant.cyan; bg = variant.cyan; };
        marker_selected = { fg = variant.yellow; bg = variant.yellow; };

        count_copied = { fg = variant.background; bg = variant.green; };
        count_cut = onPinkDeep;
        count_selected = onPink;

        border_style = border;
      };

      tabs = {
        active = onPink // { bold = true; };
        inactive = subtle;
      };

      # Main badges match the tmux bar: pink, purple and deep pink. Alt
      # badges (size, percent) are plain text, too small an area to carry
      # those accents at readable contrast.
      mode = {
        normal_main = onPink // { bold = true; };
        normal_alt = { fg = variant.foreground; bg = variant.selection; };
        select_main = onPurple // { bold = true; };
        select_alt = { fg = variant.foreground; bg = variant.selection; };
        unset_main = onPinkDeep // { bold = true; };
        unset_alt = { fg = variant.foreground; bg = variant.selection; };
      };

      indicator = {
        current = onPink;
        parent = subtle;
        preview = { underline = true; };
      };

      status = {
        perm_sep = border;
        perm_type = { fg = variant.green; };
        perm_read = { fg = variant.yellow; };
        perm_write = { fg = variant.pink; };
        perm_exec = { fg = variant.cyan; };
        progress_label = { bold = true; };
        progress_normal = { fg = variant.green; bg = variant.selection; };
        progress_error = onPinkDeep;
      };

      which = {
        inherit border;
        cand = { fg = variant.cyan; };
        rest = { fg = variant.foreground; dim = true; };
        desc = { fg = variant.purple; };
        separator_style = border;
      };

      confirm = {
        inherit border title;
        btn_yes = onPink // { bold = true; };
        btn_no = { fg = variant.foreground; };
      };

      spot = {
        inherit border title;
        tbl_col = { fg = variant.pink; };
        tbl_cell = { fg = variant.yellow; reversed = true; };
      };

      notify = {
        title_info = { fg = variant.green; };
        title_warn = { fg = variant.yellow; };
        title_error = { fg = variant.pink; };
      };

      pick = {
        inherit border;
        active = { fg = variant.pink; bold = true; };
      };

      input = {
        inherit border title;
        selected = onPink;
      };

      cmp = {
        inherit border;
        active = onPink;
      };

      tasks = {
        inherit border title;
        hovered = onPink;
      };

      help = {
        inherit border;
        chord = { fg = variant.cyan; };
        action = { fg = variant.foreground; };
        hovered = onPink // { bold = true; };
      };

      filetype.rules = [
        { mime = "**/image/*"; fg = variant.yellow; }
        { mime = "**/{audio,video}/*"; fg = variant.purple; }
        { mime = "**/application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = variant.pink; }
        { mime = "**/application/{pdf,doc,rtf}"; fg = variant.cyan; }
        { mime = "vfs/{absent,stale}"; fg = variant.border; }
        { url = "*"; is = "orphan"; fg = palette.white; bg = palette.pinkDeep; }
        { url = "*"; is = "exec"; fg = variant.green; }
        { url = "*"; is = "dummy"; fg = palette.white; bg = palette.pinkDeep; }
        { url = "*/"; is = "dummy"; fg = palette.white; bg = palette.pinkDeep; }
        { url = "*/"; fg = variant.blue; }
      ];
    };

  # A flavor is a directory holding flavor.toml. tmtheme.xml is optional: when
  # it is missing yazi falls back to its ANSI highlighter theme, which already
  # takes its colours from the terminal palette.
  mkFlavorDir = name: variant:
    pkgs.linkFarm "${name}.yazi" [
      {
        name = "flavor.toml";
        path = tomlFormat.generate "${name}-flavor.toml" (mkFlavor variant);
      }
    ];
in
{
  programs.yazi = {
    enable = true;

    # `yy` opens yazi and cds into the directory you quit from. Not `y`, because
    # the oh-my-zsh yarn plugin (zsh.nix) already aliases y and ya to yarn.
    shellWrapperName = "yy";

    # The nixpkgs wrapper already puts fd, ripgrep, fzf, zoxide, 7zz, ffmpeg,
    # poppler, imagemagick, chafa and resvg on yazi's PATH.
    settings = {
      opener.edit = [
        { run = "vim %s"; block = true; desc = "vim"; for = "unix"; }
      ];
    };

    theme.flavor = {
      dark = "tinacious-dark";
      light = "tinacious-light";
    };

    flavors = {
      tinacious-dark = mkFlavorDir "tinacious-dark" darkText;
      tinacious-light = mkFlavorDir "tinacious-light" lightText;
    };
  };
}
