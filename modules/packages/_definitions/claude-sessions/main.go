package main

import (
	"flag"
	"fmt"
	"os"
	"runtime"
	"strconv"
	"strings"
	"time"
)

func usage() {
	fmt.Fprint(os.Stderr, `Usage: claude-sessions [OPTIONS]

List Claude Code sessions broken down into tasks, useful for hours registration.

Options:
  -d, --day [N]     Show tasks from today, or the last N days if N given
  -w, --week        Show tasks from the current week (since Monday)
  -l, --last-week   Show tasks from last week (Mon-Sun)
  -a, --all         Show all tasks (default)
      --gap MIN     Idle-gap threshold in minutes that splits tasks (default 15)
      --json        Emit JSON instead of the table
      --no-summarize  Skip the Claude haiku summary call
      --project P   Filter by cwd prefix
  -h, --help        Show this help
`)
}

type options struct {
	since       time.Time
	until       time.Time
	hasSince    bool
	hasUntil    bool
	gap         time.Duration
	json        bool
	noSummarize bool
	projectFilt string
}

func parseArgs(args []string) (options, error) {
	o := options{gap: 15 * time.Minute}
	i := 0
	for i < len(args) {
		a := args[i]
		switch a {
		case "-h", "--help":
			usage()
			os.Exit(0)
		case "-a", "--all":
			i++
		case "-w", "--week":
			now := time.Now()
			weekday := int(now.Weekday())
			if weekday == 0 {
				weekday = 7
			}
			monday := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location()).AddDate(0, 0, -(weekday - 1))
			o.since, o.hasSince = monday, true
			i++
		case "-l", "--last-week":
			now := time.Now()
			weekday := int(now.Weekday())
			if weekday == 0 {
				weekday = 7
			}
			thisMonday := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location()).AddDate(0, 0, -(weekday - 1))
			lastMonday := thisMonday.AddDate(0, 0, -7)
			o.since, o.hasSince = lastMonday, true
			o.until, o.hasUntil = thisMonday, true
			i++
		case "-d", "--day", "--days":
			i++
			now := time.Now()
			days := 0
			if i < len(args) {
				if n, err := strconv.Atoi(args[i]); err == nil {
					days = n
					i++
				}
			}
			start := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
			if days > 0 {
				start = start.AddDate(0, 0, -days)
			}
			o.since, o.hasSince = start, true
		case "--gap":
			i++
			if i >= len(args) {
				return o, fmt.Errorf("--gap requires a value")
			}
			n, err := strconv.Atoi(args[i])
			if err != nil {
				return o, fmt.Errorf("--gap: %w", err)
			}
			o.gap = time.Duration(n) * time.Minute
			i++
		case "--json":
			o.json = true
			i++
		case "--no-summarize":
			o.noSummarize = true
			i++
		case "--project":
			i++
			if i >= len(args) {
				return o, fmt.Errorf("--project requires a value")
			}
			o.projectFilt = args[i]
			i++
		default:
			if strings.HasPrefix(a, "-") {
				return o, fmt.Errorf("unknown option: %s", a)
			}
			return o, fmt.Errorf("unexpected argument: %s", a)
		}
	}
	return o, nil
}

func main() {
	flag.Usage = usage
	opts, err := parseArgs(os.Args[1:])
	if err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		usage()
		os.Exit(2)
	}

	events, err := loadAllSessions()
	if err != nil {
		fmt.Fprintln(os.Stderr, "error loading sessions:", err)
		os.Exit(1)
	}

	tasks := segmentSessions(events, opts.gap)

	filtered := tasks[:0]
	for _, t := range tasks {
		if opts.hasSince && t.Start.Before(opts.since) {
			continue
		}
		if opts.hasUntil && !t.Start.Before(opts.until) {
			continue
		}
		if opts.projectFilt != "" && !strings.HasPrefix(t.Cwd, opts.projectFilt) {
			continue
		}
		filtered = append(filtered, t)
	}
	tasks = filtered

	if len(tasks) == 0 {
		fmt.Println("No tasks found.")
		return
	}

	summarizeAll(tasks, opts.noSummarize, runtime.NumCPU())

	if opts.json {
		if err := renderJSON(os.Stdout, tasks); err != nil {
			fmt.Fprintln(os.Stderr, "json:", err)
			os.Exit(1)
		}
		return
	}
	renderTable(os.Stdout, tasks)
}
