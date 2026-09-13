-- Launch ruby-lsp through `direnv exec` rooted at the current dir. In a direnv
-- project (.envrc + `layout ruby`) this puts .direnv/ruby/bin first on PATH, so
-- the ruby-lsp gem built against the project's Ruby is used and its native gems
-- link the matching libruby.so. In a non-direnv project, `direnv exec` is a
-- no-op and PATH falls through to the ruby-lsp from extraPackages.
--
-- `.` (cwd) rather than root_dir: cmd is a plain table, evaluated before the
-- root is resolved. direnv walks up from cwd to find .envrc anyway.
return {
  cmd = { "direnv", "exec", ".", "ruby-lsp" },
}
