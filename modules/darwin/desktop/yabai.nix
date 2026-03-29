{ ... }:
{
  services.yabai = {
    enable = true;
    enableScriptingAddition = false;
    config = { };
    extraConfig = builtins.readFile ./yabairc;
  };
}
