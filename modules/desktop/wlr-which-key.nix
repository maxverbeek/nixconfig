{ config, ... }:
{
  flake.modules.homeManager.wlr-which-key = {
    # this stuff is generic and exported on flake level as an extension type thing..
    imports = [ config.flake.homeModules.wlr-which-key ];

    programs.wlr-which-key = {
      enable = true;

      config.menu = [
        {
          key = "p";
          desc = "1password";
          cmd = "1password";
        }
        {
          key = "n";
          desc = "Notes (obsidian)";
          cmd = "obsidian";
        }
        {
          key = "b";
          desc = "Browser (zen)";
          cmd = "zen-beta";
        }
      ];
    };
  };
}
