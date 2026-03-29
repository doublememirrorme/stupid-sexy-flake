{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vim
    pkgs.tmux
    pkgs.zsh
    pkgs.tldr
    pkgs.docker
    pkgs.jq
    pkgs.openssl
    pkgs.ncdu
    pkgs.htop
    pkgs.gh
    pkgs.fastfetch
    pkgs.nodejs_24
    pkgs.pnpm
    pkgs.yarn
    pkgs.nicotine-plus
    pkgs.yt-dlp
    pkgs.beets
    pkgs.flac
  ];
}
