#!/usr/bin/env bash
# Prints just the rate-limit segment: "5% 28%W" (5-hour, then whichever weekly
# bucket binds first). All percentages are USED, not remaining.
#
# Starship's claude-code statusline provider covers model, directory, branch,
# context gauge and cost, but has no rate-limit module — this fills that one gap
# and is wired in as a [custom] module.
#
# Reads only. barbell's ClaudeUsage.qml polls the OAuth usage endpoint every 5
# minutes and tees the reply to the cache below; a second poller on that
# endpoint is how you earn a 429.
set -uo pipefail

# The 5-hour bucket is in the statusline payload. Starship passes it on stdin to
# the provider, but NOT to custom modules, so read the tee'd copy instead.
dump="${XDG_RUNTIME_DIR:-/tmp}/claude-usage.json"
five=$(jq -r '.rate_limits.five_hour.used_percentage // empty' "$dump" 2>/dev/null)

cache="${XDG_RUNTIME_DIR:-/tmp}/claude-usage-limits.json"
# Older than ~15 min means nothing is driving the file. A weekly quota from
# yesterday is indistinguishable from a live one, so drop it rather than show it.
if [ -s "$cache" ] &&
   [ $(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) )) -gt 900 ]; then
    cache=""
fi

weekly=""
if [ -n "$cache" ] && [ -s "$cache" ]; then
    # The scoped weekly is not gated on the running model: the API reports it as
    # scope "Fable" with is_active true even while Opus runs, because it is the
    # plan's premium-model weekly and Opus draws it too. Trust is_active, not the
    # model string.
    #
    # A premium model burns the general weekly ~2x as fast, so compare that
    # bucket's used% DOUBLED against the scoped one. The doubling only picks
    # which bucket to show; the winner prints its own real used%, tagged W or F.
    weekly=$(jq -r '
        (.limits // []) as $l
        | (($l[] | select(.kind == "weekly_all") | .percent) // empty) as $all
        | ([$l[] | select(.kind == "weekly_scoped" and .is_active) | .percent]
            | first) as $scoped
        | if $all == null then empty else
            if $scoped == null then "\($all | floor)%W"
            elif ($all * 2) >= $scoped then "\($all | floor)%W"
            else "\($scoped | floor)%F"
            end
          end
    ' "$cache" 2>/dev/null)
fi

f="?%"
[ -n "$five" ] && f="$(awk -v v="$five" 'BEGIN{printf "%d", v}')%"
printf '%s %s' "$f" "${weekly:-?}"
