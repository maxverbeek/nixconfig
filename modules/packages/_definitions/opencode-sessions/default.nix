{
  lib,
  writeShellApplication,
  sqlite,
}:

writeShellApplication {
  name = "opencode-sessions";
  runtimeInputs = [
    sqlite
  ];
  text = builtins.readFile ./opencode-sessions.sh;
  meta = {
    description = "List opencode sessions across all projects";
    license = lib.licenses.mit;
  };
}
