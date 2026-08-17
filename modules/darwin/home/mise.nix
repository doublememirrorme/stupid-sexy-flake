{ lib, ... }:
{
  # Replaces the `eval "$(~/.local/bin/mise activate)"` line that was stranded in
  # the dead ~/.zshrc, so mise activation is part of the config again.
  #
  # Not using home-manager's `programs.mise`: it requires `pkgs.mise`, which
  # currently fails to build on darwin because its direnv dependency hits
  # "-linkmode=external requires external (cgo) linking, but cgo is not enabled".
  # Setting `package = null` is not a way out either, the module then asserts and
  # emits no activation at all. mise comes from homebrew instead (see
  # homebrew.nix), which keeps it declared and repeatable.
  #
  # Resolved through PATH rather than an absolute path, so this keeps working if
  # mise later moves back to nixpkgs.
  programs.zsh.initContent = lib.mkOrder 300 ''
    if command -v mise >/dev/null 2>&1; then
      eval "$(mise activate zsh)"
    fi
  '';
}
