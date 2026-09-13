package main

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

const summarizerInstruction = `You are summarizing a single development task. Below are the user prompts spoken in chronological order, followed (optionally) by plan documents the developer wrote. Output ONE concise plain-text title describing the work, max 12 words. No markdown, no quotes, no asterisks, no bold, no trailing period. Focus on the concrete subject of the work, not the meta ("user asked about X" → "X").`

func cacheDir() string {
	if v := os.Getenv("XDG_CACHE_HOME"); v != "" {
		return filepath.Join(v, "claude-sessions")
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".cache", "claude-sessions")
}

func taskHash(t *Task) string {
	h := sha256.New()
	for _, p := range t.Prompts {
		h.Write([]byte(p))
		h.Write([]byte{0})
	}
	for _, pl := range t.Plans {
		h.Write([]byte(pl.Path))
		h.Write([]byte{0})
		h.Write([]byte(pl.Content))
		h.Write([]byte{0})
	}
	return hex.EncodeToString(h.Sum(nil))[:32]
}

func buildSummarizerInput(t *Task) string {
	var b strings.Builder
	b.WriteString("USER PROMPTS:\n")
	for i, p := range t.Prompts {
		if i > 0 {
			b.WriteString("\n---\n")
		}
		if len(p) > 1500 {
			p = p[:1500] + "…"
		}
		b.WriteString(p)
	}
	if len(t.Plans) > 0 {
		b.WriteString("\n\nPLAN DOCUMENTS WRITTEN DURING TASK:\n")
		for i, pl := range t.Plans {
			if i > 0 {
				b.WriteString("\n---\n")
			}
			c := pl.Content
			if len(c) > 4000 {
				c = c[:4000] + "…"
			}
			fmt.Fprintf(&b, "[%s] %s\n%s", pl.Tool, pl.Path, c)
		}
	}
	return b.String()
}

func summarizeAll(tasks []Task, noSummarize bool, concurrency int) {
	dir := cacheDir()
	_ = os.MkdirAll(dir, 0o755)

	if concurrency < 1 {
		concurrency = 4
	}
	sem := make(chan struct{}, concurrency)
	var wg sync.WaitGroup
	for i := range tasks {
		i := i
		wg.Add(1)
		sem <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-sem }()
			tasks[i].Summary = summarizeTask(&tasks[i], noSummarize, dir)
		}()
	}
	wg.Wait()
}

func summarizeTask(t *Task, noSummarize bool, cacheRoot string) string {
	fallback := fallbackSummary(t)
	if noSummarize {
		return fallback
	}

	hash := taskHash(t)
	cachePath := filepath.Join(cacheRoot, hash)
	if data, err := os.ReadFile(cachePath); err == nil {
		s := strings.TrimSpace(string(data))
		if s != "" {
			return s
		}
	}

	input := buildSummarizerInput(t)
	if input == "" {
		return fallback
	}

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "claude", "-p", "--model", "haiku", "--no-session-persistence",
		summarizerInstruction+"\n\n"+input)
	cmd.Dir = os.TempDir()
	out, err := cmd.Output()
	if err != nil {
		return fallback
	}
	summary := cleanSummary(string(out))
	if summary == "" {
		return fallback
	}
	_ = os.WriteFile(cachePath, []byte(summary), 0o644)
	return summary
}

func cleanSummary(raw string) string {
	s := strings.TrimSpace(raw)
	// Take last non-empty line, in case Claude added preamble.
	lines := strings.Split(s, "\n")
	for i := len(lines) - 1; i >= 0; i-- {
		l := strings.TrimSpace(lines[i])
		if l == "" {
			continue
		}
		s = l
		break
	}
	s = strings.Trim(s, "\"'`*_ #")
	for _, prefix := range []string{"Title:", "title:", "TITLE:", "Task:", "Summary:"} {
		if strings.HasPrefix(s, prefix) {
			s = strings.TrimSpace(s[len(prefix):])
			s = strings.Trim(s, "\"'`*_ #")
			break
		}
	}
	s = strings.TrimSuffix(s, ".")
	return s
}

func fallbackSummary(t *Task) string {
	if len(t.Prompts) == 0 {
		return "(no prompts)"
	}
	s := t.Prompts[0]
	s = strings.ReplaceAll(s, "\n", " ")
	s = strings.ReplaceAll(s, "\t", " ")
	if len(s) > 80 {
		s = s[:80] + "…"
	}
	return s
}
