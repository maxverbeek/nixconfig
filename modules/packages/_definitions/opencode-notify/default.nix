{ lib, runCommand }:

runCommand "opencode-notify" {
  meta = {
    description = "OpenCode plugin for libnotify desktop notifications with niri integration";
    license = lib.licenses.mit;
  };
} ''
  mkdir -p $out
  cp ${./opencode-notify.ts} $out/opencode-notify.ts
''
