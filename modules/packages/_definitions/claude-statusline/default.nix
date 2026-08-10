{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname = "claude-statusline";
  version = "0.1.0";
  src = ./.;
  vendorHash = null;
  subPackages = [ "." ];
  meta = {
    description = "Claude Code statusline renderer: context, model, git, rate limits from the barbell usage cache, cost";
    license = lib.licenses.mit;
    mainProgram = "claude-statusline";
  };
}
