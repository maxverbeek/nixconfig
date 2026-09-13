package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
	"text/tabwriter"
	"time"
)

func renderTable(w io.Writer, tasks []Task) {
	home, _ := os.UserHomeDir()

	// Group by date (local).
	tw := tabwriter.NewWriter(w, 0, 0, 2, ' ', 0)
	currentDate := ""
	for _, t := range tasks {
		start := t.Start.Local()
		end := t.End.Local()
		date := start.Format("2006-01-02 Mon")
		if date != currentDate {
			if currentDate != "" {
				fmt.Fprintln(tw)
			}
			fmt.Fprintf(tw, "%s\n", date)
			currentDate = date
		}
		dur := end.Sub(start).Round(time.Minute)
		project := t.Cwd
		if home != "" && strings.HasPrefix(project, home) {
			project = "~" + project[len(home):]
		}
		branch := t.GitBranch
		if branch == "" {
			branch = "-"
		}
		summary := strings.ReplaceAll(t.Summary, "\n", " ")
		if len(summary) > 100 {
			summary = summary[:100] + "…"
		}
		fmt.Fprintf(tw, "  %s–%s\t%s\t%s\t%s\t%s\n",
			start.Format("15:04"),
			end.Format("15:04"),
			formatDuration(dur),
			project,
			branch,
			summary,
		)
	}
	tw.Flush()
}

func formatDuration(d time.Duration) string {
	if d < time.Minute {
		return "<1m"
	}
	h := int(d.Hours())
	m := int(d.Minutes()) % 60
	if h == 0 {
		return fmt.Sprintf("%dm", m)
	}
	return fmt.Sprintf("%dh%02dm", h, m)
}

type jsonTask struct {
	SessionID string   `json:"session_id"`
	Cwd       string   `json:"cwd"`
	GitBranch string   `json:"git_branch"`
	Start     string   `json:"start"`
	End       string   `json:"end"`
	Duration  string   `json:"duration"`
	Summary   string   `json:"summary"`
	Prompts   []string `json:"prompts"`
}

func renderJSON(w io.Writer, tasks []Task) error {
	out := make([]jsonTask, 0, len(tasks))
	for _, t := range tasks {
		out = append(out, jsonTask{
			SessionID: t.SessionID,
			Cwd:       t.Cwd,
			GitBranch: t.GitBranch,
			Start:     t.Start.Format(time.RFC3339),
			End:       t.End.Format(time.RFC3339),
			Duration:  t.End.Sub(t.Start).Round(time.Second).String(),
			Summary:   t.Summary,
			Prompts:   t.Prompts,
		})
	}
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(out)
}
