{
  nixos.programs.pokemon-emerald =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.mgba
        (pkgs.makeDesktopItem {
          name = "pokemon-emerald";
          desktopName = "Pokémon Emerald";
          comment = "Launch Pokémon Emerald";
          exec = "/home/max/Personal/emerald-max/play.sh";
          terminal = false;
          categories = [ "Game" ];
        })
      ];
    };
}
