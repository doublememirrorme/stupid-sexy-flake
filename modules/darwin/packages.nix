{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.mkalias
    pkgs.awscli2
    pkgs.monitorcontrol
    pkgs.iterm2
    pkgs.postman
    pkgs.mas
    pkgs.fira-code
    pkgs.maccy
  ];
}
