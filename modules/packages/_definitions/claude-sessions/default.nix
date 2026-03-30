{
  lib,
  writeShellApplication,
  jq,
}:

writeShellApplication {
  name = "claude-sessions";
  runtimeInputs = [
    jq
  ];
  text = builtins.readFile ./claude-sessions.sh;
  meta = {
    description = "List Claude Code sessions across all projects";
    license = lib.licenses.mit;
  };
}
