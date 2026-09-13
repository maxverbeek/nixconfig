# A store path holding runtime-read configuration.
#
#   { pure = ./config; }
#     -> the config copied into the store: reproducible, works anywhere.
#
#   { pure = ./config; impure = "/home/max/nixconfig/..."; }
#     -> a store path that is a SYMLINK into the working tree, so edits take
#        effect without a rebuild.
#
# `impure` may only ever point at config that is READ AT RUNTIME (a neovim
# lua tree, a niri kdl file, an agent skill). Never at a build input: that
# would make the build itself non-reproducible rather than merely making the
# config editable.
#
# Every impure variant must have a pure counterpart, so hosts without the
# repository checked out (the VPS) still work.
{ runCommandLocal, lib }:
{
  pure,
  impure ? null,
}:
if impure == null then
  pure
else
  runCommandLocal "live-config" { } "ln -s ${lib.escapeShellArg impure} $out"
