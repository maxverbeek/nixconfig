{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    userEmail = "m4xv3rb33k@gmail.com";
    userName = "Max Verbeek";

    aliases = {
      s = "status";
      cm = "commit";
      co = "checkout";
      a = "add";
    };
  };

  home.stateVersion = "20.09";
  home.packages = with pkgs; [
    spotify
  ];
}
