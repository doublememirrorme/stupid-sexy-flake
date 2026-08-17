{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.mkalias
    pkgs.awscli2
    pkgs.google-cloud-sdk
    pkgs.claude-code
    pkgs.monitorcontrol
    pkgs.iterm2
    pkgs.postman
    pkgs.mas
    pkgs.fira-code
    pkgs.maccy
  ];
}
