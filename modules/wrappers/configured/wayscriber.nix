{
  # wayscriber's entry in the which-key menu.
  wrappers.configured.wlr-which-key = _: {
    settings.menu = [
      {
        key = "a";
        desc = "Annotate screen";
        cmd = "pkill -SIGUSR1 wayscriber";
      }
    ];
  };
}
