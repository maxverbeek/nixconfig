{
  wrappers.configured.herdr =
    {
      my,
      pkgs,
      lib,
      ...
    }:
    let
      directions = {
        h = "left";
        j = "down";
        k = "up";
        l = "right";
      };

      # Moves the focused pane to tab N of the focused workspace, or to a new tab when N doesn't exist.
      paneToTab = pkgs.writeShellApplication {
        name = "herdr-pane-to-tab";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          ws=$(herdr workspace list | jq -r '.result.workspaces[] | select(.focused).workspace_id')
          tabs=$(herdr tab list --workspace "$ws")
          current=$(jq -r '.result.tabs[] | select(.focused).tab_id' <<<"$tabs")
          target=$(jq -r --argjson n "$1" '.result.tabs[] | select(.number == $n).tab_id' <<<"$tabs")
          pane=$(herdr pane list --workspace "$ws" \
            | jq -r --arg t "$current" '.result.panes[] | select(.focused and .tab_id == $t).pane_id')
          if [ -n "$target" ]; then
            herdr pane move "$pane" --tab "$target"
          else
            herdr pane move "$pane" --new-tab
          fi
        '';
      };
    in
    {
      imports = [ my.modules.wrappers.modules.herdr ];
      package = pkgs.unstable.herdr;
      settings = {
        ui.agent_panel_sort = "spaces";
        keys = {
          prefix = "ctrl+a";
          last_pane = "prefix+a";
          resize_pane_left = "alt+shift+left";
          resize_pane_down = "alt+shift+down";
          resize_pane_up = "alt+shift+up";
          resize_pane_right = "alt+shift+right";
        }
        // lib.mapAttrs' (key: dir: lib.nameValuePair "focus_pane_${dir}" "alt+${key}") directions
        // {
          command =
            lib.mapAttrsToList (key: dir: {
              key = "alt+shift+${key}";
              type = "shell";
              command = "herdr pane swap --direction ${dir}";
            }) directions
            # Terminals send shift+digit as the shifted symbol (US layout).
            ++ lib.imap1 (n: sym: {
              key = "prefix+${sym}";
              type = "shell";
              command = "${lib.getExe paneToTab} ${toString n}";
            }) (lib.stringToCharacters "!@#$%^&*(");
        };
      };
    };
}
