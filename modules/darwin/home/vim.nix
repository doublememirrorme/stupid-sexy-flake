{ config, ... }:
let
  stateDir = "${config.xdg.stateHome}/vim";
in
{
  # Vim itself is pkgs.vim from modules/shared/packages.nix; this only adds a
  # vimrc. programs.vim is not used: it installs a second vim (vim-full, a GTK
  # build on darwin without the Cocoa clipboard) into the per-user profile
  # ahead of the system one, and always adds vim-sensible.
  #
  # Vim 9.1.0327+ reads $XDG_CONFIG_HOME/vim/vimrc when neither ~/.vimrc nor
  # ~/.vim/vimrc exists, which is the case here.
  xdg.configFile."vim/vimrc".text = ''
    " Start from Vim's own defaults.vim, which is skipped once a vimrc exists.
    " It gives nocompatible, incsearch, scrolloff=5, ttimeoutlen=100, syntax on,
    " filetype plugin indent on and cursor position restore.
    unlet! skip_defaults_vim
    source $VIMRUNTIME/defaults.vim

    " Mouse. defaults.vim only gives mouse=nvi under tmux-256color, and SGR
    " reporting is not autodetected through tmux (its version reply is 84, and
    " the tmux terminfo has no XM). Plain xterm mode stops past column 223.
    set mouse=a
    set ttymouse=sgr

    " macOS clipboard: this build has +clipboard, so * is the pasteboard.
    if has('clipboard')
      set clipboard=unnamed
    endif

    " Ask the terminal for its background colour (OSC 11, which tmux answers
    " on iTerm2's behalf) so 'background' follows the Tinacious light or dark
    " profile.
    " No termguicolors: the 16 ANSI colours stay the terminal's.
    let &t_RB = "\<Esc>]11;?\<Esc>\\"

    set number
    " The vimrc shipped with the vim package caps this at 50 before we run.
    set history=1000
    set hlsearch ignorecase smartcase
    set expandtab shiftwidth=2 tabstop=2 softtabstop=2 autoindent
    set hidden
    set splitright splitbelow
    set wildmode=longest:full,full

    " Keep swap, backup, undo and viminfo out of the working tree. Vim only
    " writes into directories that exist; home-manager creates them below.
    set directory=${stateDir}/swap//
    set backupdir=${stateDir}/backup//
    set undodir=${stateDir}/undo
    set undofile
    set viminfofile=${stateDir}/viminfo
    " netrw otherwise drops its history next to this vimrc.
    let g:netrw_home = '${stateDir}'
  '';

  xdg.stateFile = {
    "vim/swap/.keep".text = "";
    "vim/backup/.keep".text = "";
    "vim/undo/.keep".text = "";
  };
}
