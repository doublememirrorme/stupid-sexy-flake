{ ... }:
{
  programs.git = {
    enable = true;

    # There was no global config at all before this, only per-repo identities.
    # Personal is the default; anything under ~/Projects/bb-agency uses work.
    settings.user = {
      name = "bb-hcanadjija";
      email = "bb-hcanadjija@users.noreply.github.com";
    };

    includes = [
      {
        condition = "gitdir:~/Projects/bb-agency/";
        contents.user = {
          name = "Hrvoje Canadija";
          email = "hrvoje.canadjija@bb.agency";
        };
      }
    ];

    # Carried over from the hand-written ~/.config/git/ignore.
    ignores = [ "**/.claude/settings.local.json" ];
  };
}
