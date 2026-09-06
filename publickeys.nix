# SSH public keys, single source of truth. Not a module (root dir is outside
# import-tree); consumers do `import ./publickeys.nix` relative to themselves.
# Used by secrets.nix (agenix recipients) and available for authorized_keys /
# known_hosts config. Host keys come from /etc/ssh/ssh_host_ed25519_key.pub.
{
  max = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBmyftE9tuFUn/8m03M6aS0okxA7B1QFBxZNhP4CZ8F";
  scopecreep = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqFt90MWJNumENz3qqMg4F4C+QJus7PXCbZfudA3GvB";
}
