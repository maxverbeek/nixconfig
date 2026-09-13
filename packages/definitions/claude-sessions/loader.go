package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

type Event struct {
	Type        string          `json:"type"`
	Timestamp   time.Time       `json:"timestamp"`
	SessionID   string          `json:"sessionId"`
	Cwd         string          `json:"cwd"`
	GitBranch   string          `json:"gitBranch"`
	UUID        string          `json:"uuid"`
	ParentUUID  string          `json:"parentUuid"`
	Message     json.RawMessage `json:"message"`
}

type userMessage struct {
	Role    string          `json:"role"`
	Content json.RawMessage `json:"content"`
}

type assistantContentItem struct {
	Type  string          `json:"type"`
	Text  string          `json:"text"`
	Name  string          `json:"name"`
	Input json.RawMessage `json:"input"`
}

type assistantMessage struct {
	Role    string                 `json:"role"`
	Content []assistantContentItem `json:"content"`
}

func (e *Event) UserPromptText() (string, bool) {
	if e.Type != "user" || len(e.Message) == 0 {
		return "", false
	}
	var um userMessage
	if err := json.Unmarshal(e.Message, &um); err != nil {
		return "", false
	}
	if len(um.Content) == 0 {
		return "", false
	}
	if um.Content[0] != '"' {
		return "", false
	}
	var s string
	if err := json.Unmarshal(um.Content, &s); err != nil {
		return "", false
	}
	s = strings.TrimSpace(s)
	if s == "" {
		return "", false
	}
	if strings.HasPrefix(s, "<") {
		return "", false
	}
	if strings.HasPrefix(s, "/") {
		return "", false
	}
	return s, true
}

func (e *Event) PlanWrites() []planWrite {
	if e.Type != "assistant" || len(e.Message) == 0 {
		return nil
	}
	var am assistantMessage
	if err := json.Unmarshal(e.Message, &am); err != nil {
		return nil
	}
	var out []planWrite
	for _, item := range am.Content {
		if item.Type != "tool_use" {
			continue
		}
		if item.Name != "Write" && item.Name != "Edit" {
			continue
		}
		var input struct {
			FilePath  string `json:"file_path"`
			Content   string `json:"content"`
			NewString string `json:"new_string"`
		}
		if err := json.Unmarshal(item.Input, &input); err != nil {
			continue
		}
		if !strings.Contains(input.FilePath, "/.claude/plans/") {
			continue
		}
		text := input.Content
		if text == "" {
			text = input.NewString
		}
		if text == "" {
			continue
		}
		out = append(out, planWrite{Path: input.FilePath, Content: text, Tool: item.Name})
	}
	return out
}

type planWrite struct {
	Path    string
	Content string
	Tool    string
}

func projectsRoot() string {
	if v := os.Getenv("CLAUDE_PROJECTS_DIR"); v != "" {
		return v
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".claude", "projects")
}

func loadAllSessions() ([]Event, error) {
	root := projectsRoot()
	var events []Event
	entries, err := os.ReadDir(root)
	if err != nil {
		return nil, fmt.Errorf("read projects dir: %w", err)
	}
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		dir := filepath.Join(root, e.Name())
		files, err := os.ReadDir(dir)
		if err != nil {
			continue
		}
		for _, f := range files {
			if f.IsDir() || !strings.HasSuffix(f.Name(), ".jsonl") {
				continue
			}
			path := filepath.Join(dir, f.Name())
			evs, err := loadSessionFile(path)
			if err != nil {
				fmt.Fprintf(os.Stderr, "warn: %s: %v\n", path, err)
				continue
			}
			events = append(events, evs...)
		}
	}
	return events, nil
}

func loadSessionFile(path string) ([]Event, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	var out []Event
	scanner := bufio.NewScanner(f)
	scanner.Buffer(make([]byte, 1024*1024), 64*1024*1024)
	for scanner.Scan() {
		line := scanner.Bytes()
		if len(line) == 0 {
			continue
		}
		var ev Event
		if err := json.Unmarshal(line, &ev); err != nil {
			continue
		}
		if ev.Type == "" || ev.Timestamp.IsZero() || ev.SessionID == "" {
			continue
		}
		out = append(out, ev)
	}
	return out, scanner.Err()
}
