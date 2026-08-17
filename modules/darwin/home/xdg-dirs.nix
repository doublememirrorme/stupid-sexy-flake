{ config, ... }:
let
  cfgHome = config.xdg.configHome;
  stateHome = config.xdg.stateHome;
in
{
  # Keeps config and history out of $HOME by pointing each tool at an XDG path.
  # Only variables checked against the tool that actually reads them are listed
  # here: an env var the tool ignores would silently strand its config in $HOME.
  home.sessionVariables = {
    # Verified: `NPM_CONFIG_USERCONFIG=... npm config get userconfig` follows it.
    NPM_CONFIG_USERCONFIG = "${cfgHome}/npm/npmrc";

    # Verified: `BOTO_CONFIG=... gsutil version -l` drops ~/.boto from its paths.
    BOTO_CONFIG = "${cfgHome}/gcloud/boto";
    CLOUDSDK_CONFIG = "${cfgHome}/gcloud";

    # Verified against the less and node man pages respectively.
    LESSHISTFILE = "${stateHome}/less/history";
    NODE_REPL_HISTORY = "${stateHome}/node/repl_history";

    # psql is not installed here, so this is unverified but harmless until it is.
    PSQL_HISTORY = "${stateHome}/psql/history";
  };
}
