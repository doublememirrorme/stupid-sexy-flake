{ config, lib, ... }:
let
  home = config.home.homeDirectory;

  # The work account keeps the default config dir. The personal account gets its
  # own, because Claude Code stores exactly one sign-in per config dir and
  # CLAUDE_CONFIG_DIR is the only thing that moves it.
  workDir = "${home}/.claude";
  personalDir = "${home}/.claude-personal";

  # Shared between both accounts, so settings, global instructions, skills,
  # plugins and auto-memory exist once and both accounts see the same copy.
  # Out-of-store symlinks on purpose: these point at live mutable files that
  # Claude Code writes to itself, so they must not become read-only store paths.
  shared = [ "settings.json" "CLAUDE.md" "skills" "plugins" "projects" ];

  linkShared = path: {
    name = ".claude-personal/${path}";
    value.source = config.lib.file.mkOutOfStoreSymlink "${workDir}/${path}";
  };
in
{
  # Deliberately NOT linked: .claude.json. It holds the OAuth session, the
  # personal MCP servers and per-project trust, so sharing it would collapse the
  # two accounts back into one. It stays a plain mutable file in each dir.
  home.file = builtins.listToAttrs (map linkShared shared);

  programs.zsh.initContent = lib.mkOrder 300 ''
    # Claude Code runs one account per config dir. These pick which one a
    # terminal talks to. Accounts cannot be swapped inside a running session.
    claude-work() { ( unset CLAUDE_CONFIG_DIR; command claude "$@" ); }
    claude-me()   { CLAUDE_CONFIG_DIR="${personalDir}" command claude "$@"; }

    # Flip the current terminal, then run `claude` as usual.
    # Never set CLAUDE_CONFIG_DIR to an empty string: it does not fall back to
    # the default, it makes the projects dir relative to the current folder.
    claude-use() {
      case "$1" in
        work)        unset CLAUDE_CONFIG_DIR;                     echo "this shell now uses the work account" ;;
        me|personal) export CLAUDE_CONFIG_DIR="${personalDir}";   echo "this shell now uses the personal account" ;;
        *)           echo "usage: claude-use work|me" >&2; return 2 ;;
      esac
    }

    claude-who() { command claude auth status 2>/dev/null | grep -E '"(email|orgName|subscriptionType)"'; }
  '';
}
