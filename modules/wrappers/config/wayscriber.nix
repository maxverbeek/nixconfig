{
  # wayscriber's entry in the which-key menu; the rest of wayscriber is still a
  # home-manager module and is ported later.
  wrappers.config.wlr-which-key = _: {
    settings.menu = [
      {
        key = "a";
        desc = "Annotate screen";
        cmd = "pkill -SIGUSR1 wayscriber";
      }
    ];
  };
}
