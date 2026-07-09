{ ... }:
{
  flake.modules.homeManager.personal =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.mgba ];

      xdg.desktopEntries.pokemon-emerald = {
        name = "Pokémon Emerald";
        comment = "Launch Pokémon Emerald";
        exec = "/home/max/Personal/emerald-max/play.sh";
        terminal = false;
        categories = [ "Game" ];
      };
    };
}
