{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.qbittorrent
    pkgs.radarr
    pkgs.sonarr
    pkgs.prowlarr
  ];
}
