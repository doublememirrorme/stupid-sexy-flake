{ pkgs, ... }:
let
  palette = import ./tinacious-palette.nix;
  tomlFormat = pkgs.formats.toml { };

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
      title = { fg = palette.pink; bold = true; };
    in
    {
      mgr = {
        cwd = { fg = palette.pink; bold = true; };
        find_keyword = { fg = variant.yellow; bold = true; italic = true; underline = true; };
        find_position = { fg = palette.purple; bg = "reset"; bold = true; italic = true; };
        symlink_target = { fg = palette.cyan; italic = true; };

        marker_copied = { fg = variant.green; bg = variant.green; };
        marker_cut = { fg = palette.pink; bg = palette.pink; };
        marker_marked = { fg = palette.cyan; bg = palette.cyan; };
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

      # Same trio as the tmux bar: pink, deep pink and purple.
      mode = {
        normal_main = onPink // { bold = true; };
        normal_alt = { fg = palette.pink; bg = variant.selection; };
        select_main = onPurple // { bold = true; };
        select_alt = { fg = palette.purple; bg = variant.selection; };
        unset_main = onPinkDeep // { bold = true; };
        unset_alt = { fg = palette.pinkDeep; bg = variant.selection; };
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
        perm_write = { fg = palette.pink; };
        perm_exec = { fg = palette.cyan; };
        progress_label = { bold = true; };
        progress_normal = { fg = variant.green; bg = variant.selection; };
        progress_error = { fg = variant.yellow; bg = palette.pinkDeep; };
      };

      which = {
        inherit border;
        cand = { fg = palette.cyan; };
        rest = { fg = variant.foreground; dim = true; };
        desc = { fg = palette.purple; };
        separator_style = border;
      };

      confirm = {
        inherit border title;
        btn_yes = onPink // { bold = true; };
        btn_no = { fg = variant.foreground; };
      };

      spot = {
        inherit border title;
        tbl_col = { fg = palette.pink; };
        tbl_cell = { fg = variant.yellow; reversed = true; };
      };

      notify = {
        title_info = { fg = variant.green; };
        title_warn = { fg = variant.yellow; };
        title_error = { fg = palette.pink; };
      };

      pick = {
        inherit border;
        active = { fg = palette.pink; bold = true; };
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
        chord = { fg = palette.cyan; };
        action = { fg = variant.foreground; };
        hovered = onPink // { bold = true; };
      };

      filetype.rules = [
        { mime = "**/image/*"; fg = variant.yellow; }
        { mime = "**/{audio,video}/*"; fg = palette.purple; }
        { mime = "**/application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = palette.pink; }
        { mime = "**/application/{pdf,doc,rtf}"; fg = palette.cyan; }
        { mime = "vfs/{absent,stale}"; fg = variant.border; }
        { url = "*"; is = "orphan"; bg = palette.pinkDeep; }
        { url = "*"; is = "exec"; fg = variant.green; }
        { url = "*"; is = "dummy"; bg = palette.pinkDeep; }
        { url = "*/"; is = "dummy"; bg = palette.pinkDeep; }
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
      tinacious-dark = mkFlavorDir "tinacious-dark" palette.dark;
      tinacious-light = mkFlavorDir "tinacious-light" palette.light;
    };
  };
}
