{
  wrappers.configured.alacritty =
    { my, wlib, ... }:
    {
      imports = [ wlib.wrapperModules.alacritty ];

      settings.font.size = 12;
      settings.colors = my.pkgs.kanagawa-nvim.colors.alacritty;
    };
}
