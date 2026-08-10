// Claude Code statusline: one binary, no starship, no hooks.
//
// Reads the render payload Claude hands the statusline command on stdin, and
// the OAuth usage cache that barbell's ClaudeUsage.qml poller tees to
// $XDG_RUNTIME_DIR/claude-usage-limits.json every five minutes. Nothing here
// polls the usage endpoint itself — a second poller is how you earn a 429 —
// and nothing writes anywhere, so the statusline stays a pure renderer.
//
// Output: tokens (ctx%) · model · dir on branch · 5h% weekly% · cost, with an
// extra red ⚡ while extra-usage credits are burning.
package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

type payload struct {
	Model struct {
		ID string `json:"id"`
	} `json:"model"`
	Workspace struct {
		CurrentDir string `json:"current_dir"`
	} `json:"workspace"`
	CWD           string `json:"cwd"`
	ContextWindow struct {
		// Pointers, not values: before the first message these are null, and
		// a strict decoder rejecting the whole payload is exactly the failure
		// mode (starship's) this binary replaces.
		UsedPercentage *float64            `json:"used_percentage"`
		CurrentUsage   map[string]*float64 `json:"current_usage"`
	} `json:"context_window"`
	Cost struct {
		TotalCostUSD *float64 `json:"total_cost_usd"`
	} `json:"cost"`
}

type usageCache struct {
	Limits []struct {
		Kind     string   `json:"kind"`
		Percent  *float64 `json:"percent"`
		IsActive bool     `json:"is_active"`
	} `json:"limits"`
	ExtraUsage struct {
		UsedCredits       float64 `json:"used_credits"`
		SpendLimitReached bool    `json:"spend_limit_reached"`
	} `json:"extra_usage"`
}

const (
	reset  = "\033[0m"
	red    = "\033[1;31m"
	green  = "\033[1;32m"
	yellow = "\033[1;33m"
	blue   = "\033[1;34m"
	purple = "\033[1;35m"
	cyan   = "\033[1;36m"
	dim    = "\033[2m"
)

func paint(color, s string) string { return color + s + reset }

func main() {
	var p payload
	// A payload that fails to decode still renders whatever half-filled
	// struct came out of it; a blank-but-alive line beats an error.
	_ = json.NewDecoder(os.Stdin).Decode(&p)

	var segs []string

	if s := contextSeg(p); s != "" {
		segs = append(segs, s)
	}
	if s := modelSeg(p); s != "" {
		segs = append(segs, s)
	}
	if s := dirSeg(p); s != "" {
		segs = append(segs, s)
	}
	segs = append(segs, quotaSeg())
	if s := costSeg(p); s != "" {
		segs = append(segs, s)
	}

	fmt.Print(strings.Join(segs, " "))
}

// "77813 (8%)", coloured by how much of the window is gone: green from the
// start, yellow past 10%, red past 40%. On the 1M window that is 100k/400k;
// on a 200k model the same percentages are proportionally the same warning.
func contextSeg(p payload) string {
	pct := 0.0
	if p.ContextWindow.UsedPercentage != nil {
		pct = *p.ContextWindow.UsedPercentage
	}
	// The live context is the current prompt's token total, not the session
	// cumulative — sum whatever token counts current_usage reports.
	tokens := 0.0
	for _, v := range p.ContextWindow.CurrentUsage {
		if v != nil {
			tokens += *v
		}
	}
	color := green
	switch {
	case pct >= 40:
		color = red
	case pct >= 10:
		color = yellow
	}
	count := fmt.Sprintf("%.0f", tokens)
	if tokens >= 1000 {
		count = fmt.Sprintf("%.0fk", tokens/1000)
	}
	return paint(color, fmt.Sprintf("%s (%.0f%%)", count, pct))
}

// "fable-5", the technical name rather than the marketing one: the payload id
// minus its redundant vendor prefix. The 1M-context marker needs no handling —
// the id itself is spelled "...-5[1m]".
func modelSeg(p payload) string {
	id := strings.TrimPrefix(p.Model.ID, "claude-")
	if id == "" {
		return ""
	}
	return paint(blue, id)
}

// "nixconfig on master": directory basename plus git branch, read straight
// from .git/HEAD — no git subprocess on every render.
func dirSeg(p payload) string {
	dir := p.Workspace.CurrentDir
	if dir == "" {
		dir = p.CWD
	}
	if dir == "" {
		return ""
	}
	seg := paint(cyan, filepath.Base(dir))
	if branch := gitBranch(dir); branch != "" {
		seg += dim + " on " + reset + paint(purple, branch)
	}
	return seg
}

func gitBranch(dir string) string {
	for d := dir; ; d = filepath.Dir(d) {
		gitPath := filepath.Join(d, ".git")
		if fi, err := os.Stat(gitPath); err == nil {
			if !fi.IsDir() {
				// Worktree: .git is a file, "gitdir: <path>".
				b, err := os.ReadFile(gitPath)
				if err != nil {
					return ""
				}
				gitPath = strings.TrimSpace(strings.TrimPrefix(string(b), "gitdir:"))
			}
			head, err := os.ReadFile(filepath.Join(gitPath, "HEAD"))
			if err != nil {
				return ""
			}
			ref := strings.TrimSpace(string(head))
			if name, ok := strings.CutPrefix(ref, "ref: refs/heads/"); ok {
				return name
			}
			if len(ref) >= 7 { // detached
				return ref[:7]
			}
			return ""
		}
		if d == filepath.Dir(d) {
			return ""
		}
	}
}

// "14% 30%F" — the 5h bucket, then whichever weekly bucket binds first, plus
// a red ⚡ while extra-usage credits are burning. All percentages are USED.
// Sourced from the poller cache only; "?% ?" when the poller stopped
// answering (~three missed 5-minute polls), because a quota number from
// yesterday is indistinguishable from a live one.
func quotaSeg() string {
	path := filepath.Join(runtimeDir(), "claude-usage-limits.json")
	fi, err := os.Stat(path)
	if err != nil || time.Since(fi.ModTime()) > 15*time.Minute {
		return paint(purple, "?% ?")
	}
	b, err := os.ReadFile(path)
	if err != nil {
		return paint(purple, "?% ?")
	}
	var c usageCache
	if json.Unmarshal(b, &c) != nil {
		return paint(purple, "?% ?")
	}

	five, all, scoped := "?%", (*float64)(nil), (*float64)(nil)
	for _, l := range c.Limits {
		if l.Percent == nil {
			continue
		}
		switch l.Kind {
		case "session":
			five = fmt.Sprintf("%.0f%%", *l.Percent)
		case "weekly_all":
			all = l.Percent
		case "weekly_scoped":
			// The scoped weekly is not gated on the running model: the API
			// reports it as scope "Fable" with is_active true even while Opus
			// runs, because it is the plan's premium-model weekly and Opus
			// draws it too. Trust is_active, not the model string.
			if l.IsActive && scoped == nil {
				scoped = l.Percent
			}
		}
	}

	// Show whichever weekly bucket is closest to exhausting — that's the one
	// that will actually stop you. Comparing raw used% is the whole rule.
	weekly := "?"
	switch {
	case all != nil && (scoped == nil || *all >= *scoped):
		weekly = fmt.Sprintf("%.0f%%W", *all)
	case scoped != nil:
		weekly = fmt.Sprintf("%.0f%%F", *scoped)
	}

	seg := paint(purple, five+" "+weekly)
	// The endpoint reports overage explicitly: used_credits > 0 means extra
	// credits are actually being spent, spend_limit_reached means the cap is
	// hit. Either way the subscription no longer covers the work.
	if c.ExtraUsage.UsedCredits > 0 || c.ExtraUsage.SpendLimitReached {
		seg += " " + paint(red, "⚡")
	}
	return seg
}

func costSeg(p payload) string {
	if p.Cost.TotalCostUSD == nil {
		return paint(green, "💰 $0.00")
	}
	return paint(green, fmt.Sprintf("💰 $%.2f", *p.Cost.TotalCostUSD))
}

func runtimeDir() string {
	if d := os.Getenv("XDG_RUNTIME_DIR"); d != "" {
		return d
	}
	return "/tmp"
}
