{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname = "claude-sessions";
  version = "0.2.0";
  src = ./.;
  vendorHash = null;
  subPackages = [ "." ];
  meta = {
    description = "List Claude Code sessions broken down into tasks, useful for hours registration";
    license = lib.licenses.mit;
    mainProgram = "claude-sessions";
  };
}
