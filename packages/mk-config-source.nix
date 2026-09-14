# A store path holding runtime-read configuration. `impure` makes it a symlink
# into the working tree, so edits take effect without a rebuild; it may ONLY
# point at config READ AT RUNTIME, never at a build input. Every impure variant
# needs a pure counterpart for hosts without the repo checked out (the VPS).
{ runCommandLocal, lib }:
{
  pure,
  impure ? null,
}:
if impure == null then
  pure
else
  runCommandLocal "live-config" { } "ln -s ${lib.escapeShellArg impure} $out"
