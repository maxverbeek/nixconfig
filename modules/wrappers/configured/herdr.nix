{
  wrappers.configured.herdr =
    { my, pkgs, ... }:
    {
      imports = [ my.modules.wrappers.modules.herdr ];
      package = pkgs.unstable.herdr;
      settings.ui.agent_panel_sort = "spaces";
    };
}
