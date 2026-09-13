package main

import (
	"sort"
	"time"
)

type Task struct {
	SessionID string
	Cwd       string
	GitBranch string
	Start     time.Time
	End       time.Time
	Prompts   []string
	Plans     []planWrite
	Summary   string
}

func segmentSessions(events []Event, gap time.Duration) []Task {
	bySession := map[string][]Event{}
	for _, e := range events {
		bySession[e.SessionID] = append(bySession[e.SessionID], e)
	}

	var tasks []Task
	for _, evs := range bySession {
		sort.Slice(evs, func(i, j int) bool { return evs[i].Timestamp.Before(evs[j].Timestamp) })
		tasks = append(tasks, segmentOne(evs, gap)...)
	}
	sort.Slice(tasks, func(i, j int) bool { return tasks[i].Start.After(tasks[j].Start) })
	return tasks
}

func segmentOne(evs []Event, gap time.Duration) []Task {
	// Identify indices of real user prompts.
	type promptIdx struct {
		idx  int
		text string
		ts   time.Time
	}
	var prompts []promptIdx
	for i, e := range evs {
		if t, ok := e.UserPromptText(); ok {
			prompts = append(prompts, promptIdx{idx: i, text: t, ts: e.Timestamp})
		}
	}
	if len(prompts) == 0 {
		return nil
	}

	// Compute task boundaries: a new task starts when the gap from the
	// previous prompt exceeds the threshold.
	var groups [][]promptIdx
	cur := []promptIdx{prompts[0]}
	for i := 1; i < len(prompts); i++ {
		if prompts[i].ts.Sub(prompts[i-1].ts) > gap {
			groups = append(groups, cur)
			cur = nil
		}
		cur = append(cur, prompts[i])
	}
	groups = append(groups, cur)

	var tasks []Task
	for gi, g := range groups {
		startIdx := g[0].idx
		var maxIdx int
		if gi+1 < len(groups) {
			maxIdx = groups[gi+1][0].idx - 1
		} else {
			maxIdx = len(evs) - 1
		}
		// Trim trailing events: keep extending end while consecutive events
		// stay within `gap` of each other. This avoids inflating end_ts when
		// the assistant chain finishes and the user comes back days later.
		endIdx := startIdx
		prevTs := evs[startIdx].Timestamp
		for k := startIdx + 1; k <= maxIdx; k++ {
			if evs[k].Timestamp.Sub(prevTs) > gap {
				break
			}
			endIdx = k
			prevTs = evs[k].Timestamp
		}
		task := Task{
			SessionID: evs[startIdx].SessionID,
			Cwd:       evs[startIdx].Cwd,
			GitBranch: evs[startIdx].GitBranch,
			Start:     evs[startIdx].Timestamp,
			End:       evs[endIdx].Timestamp,
		}
		seenPlan := map[string]bool{}
		for _, p := range g {
			task.Prompts = append(task.Prompts, p.text)
		}
		for k := startIdx; k <= endIdx; k++ {
			if task.Cwd == "" && evs[k].Cwd != "" {
				task.Cwd = evs[k].Cwd
			}
			if task.GitBranch == "" && evs[k].GitBranch != "" {
				task.GitBranch = evs[k].GitBranch
			}
			for _, pw := range evs[k].PlanWrites() {
				key := pw.Path + "::" + pw.Tool
				if seenPlan[key] {
					// keep only latest write to same plan path
				}
				seenPlan[key] = true
				task.Plans = append(task.Plans, pw)
			}
		}
		tasks = append(tasks, task)
	}
	return tasks
}
