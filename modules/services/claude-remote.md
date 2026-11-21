# scopecreep (VPS)

You are running on scopecreep, Max's Hetzner VPS, usually started from
claude.ai or the phone via Remote Control. Nobody is at a terminal: don't
wait on interactive prompts, and report what you did in the session.

## Machine

- NixOS, headless. No desktop, no clipboard, no browser (`wl-copy`,
  `xdg-open`, niri, foot don't exist here).
- Small: 4 cores, ~7.6 GB RAM, nix `max-jobs = 1`. Run heavy builds with
  `nice` and don't start several at once.
- It hosts live services (n8n, webdav, feedbackers, breadhero, huurhunter,
  copd, harmonia, mictap, maxtransfer). Don't stop or restart them unless
  asked. Inspect with `systemctl status` / `journalctl -u <unit>`.
- `sudo` is passwordless. Use it only for what the task needs.
- `herdr` is available for long-running panes.

## Layout

- `~/projects/<name>`: one directory per project. Remote Control sessions
  start in `~/projects`; create new projects here.
- `~/nixconfig`: checkout of `github:maxverbeek/nixconfig`, the config of
  this machine and Max's laptops.

## Changing this machine

- Edit `~/nixconfig`, then `just switch` there (pulls, then
  `nixos-rebuild switch`). Host config is
  `modules/hosts/scopecreep/default.nix`; see `modules/README.md` for the
  layout.
- Always commit and push to master right after `just switch`. The machine
  rebuilds itself from GitHub master every night at 04:00 (and may reboot),
  so anything not pushed to the remote disappears overnight.
- Commits: one-line conventional commits, no Claude footer.

## Websites

Sites live under `<name>.maxverbeek.dev`, or `<name>.maxtransfer.online`
for tests and throwaway sites (its apex is the maxtransfer service; leave
that alone). Both are served by Caddy on this machine,
which fetches certificates by itself. Each site is one leaf
`modules/services/<name>.nix` in `~/nixconfig`, imported in the scopecreep
host, then `just switch` and push.

DNS for both zones is on Cloudflare; create the record before switching so Caddy can get
its certificate. Proxied A record to this machine, like the other services:

```sh
tok=$(cat /run/agenix/cloudflare-dns-token)
zone=$(curl -s -H "Authorization: Bearer $tok" \
  "https://api.cloudflare.com/client/v4/zones?name=<zone>" | jq -r '.result[0].id')
curl -s -X POST -H "Authorization: Bearer $tok" -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/zones/$zone/dns_records" \
  --data '{"type":"A","name":"<name>","content":"46.225.230.145","proxied":true}'
```

Never touch existing records unless asked.

- Static site: build into `/srv/www/<name>` (writable by max; Caddy can't
  read `~`), and serve it with
  `services.caddy.virtualHosts."<name>.maxverbeek.dev".extraConfig = "root * /srv/www/<name>\nfile_server";`
  plus `services.caddy.enable = true;`. Later content updates are just a
  rebuild into that directory, no switch.
- App with a backend: follow the existing services, e.g.
  `modules/services/n8n.nix` (systemd service + `reverse_proxy`) or
  `modules/services/breadhero.nix` (packaged flake input in a guest with
  `proxy."<host>" = port`). Ports must not clash with other services.
- Check with `curl -I https://<name>.maxverbeek.dev` before reporting done.

## GitHub

- `gh` is authenticated as maxverbeek. New repo:
  `gh repo create maxverbeek/<name> --private --source . --push`.
  Private unless Max says otherwise.
- Git uses SSH (`git@github.com:...`).

## Tooling defaults

- Nix first: missing tool means `nix shell nixpkgs#<x>`, never global
  installs.
- Python: `uv` + `ruff`. Shell: `shellcheck`.
- Be terse.
