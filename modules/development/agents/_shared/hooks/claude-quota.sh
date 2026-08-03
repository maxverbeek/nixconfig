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

# Cost, coloured by whether the subscription still covers it. Starship's own
# claude_cost module can only threshold on the dollar amount, which says nothing
# about overage — $9 inside the subscription costs nothing extra, $9 past a
# spent weekly bucket does. That judgement needs the limit buckets, which are
# already open here, so the cost segment is emitted here too.
#
# ponytail: "exhausted" = any bucket at 100%. The API reports no explicit
# overage flag; if one appears, key off that instead.
cost=$(jq -r '.cost.total_cost_usd // empty' "$dump" 2>/dev/null)
cost_seg=""
if [ -n "$cost" ]; then
    over=0
    if [ -n "$cache" ] && [ -s "$cache" ]; then
        jq -e '[.limits[]? | select(.percent >= 100)] | length > 0' "$cache" >/dev/null 2>&1 && over=1
    fi
    # 31=red, 32=green. Starship passes a custom module's stdout through
    # untouched, so the colour has to be inline rather than via `style`.
    c=32; [ "$over" = 1 ] && c=31
    cost_seg=$(printf ' \033[1;%dm💰 $%.2f\033[0m' "$c" "$cost")
fi

printf '%s %s%s' "$f" "${weekly:-?}" "$cost_seg"
