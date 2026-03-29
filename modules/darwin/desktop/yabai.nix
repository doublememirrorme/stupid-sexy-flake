{ ... }:
{
  # Managed by launchd as org.nixos.yabai. Do not run `yabai --start-service` (installs a
  # second LaunchAgent and fights this service).
  services.yabai = {
    enable = true;
    enableScriptingAddition = false;
    config = { };
    extraConfig = builtins.readFile ./yabairc;
  };
}
