{
  lib,
  writeShellApplication,
  libnotify,
  jq,
}:

writeShellApplication {
  name = "not";
  runtimeInputs = [
    libnotify
    jq
  ];
  text = builtins.readFile ./not.sh;
  meta = {
    description = "Send a desktop notification when a long-running command finishes";
    license = lib.licenses.mit;
  };
}
