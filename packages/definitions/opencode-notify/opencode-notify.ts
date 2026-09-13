import type { Plugin } from "@opencode-ai/plugin";

const NOTIFY_SEND = "notify-send";
const NIRI_MSG = "niri";

let cachedWindowId: number | null = null;

/**
 * Walk the process tree from `pid` upward, collecting all ancestor PIDs.
 */
async function getAncestorPids(pid: number): Promise<Set<number>> {
  const ancestors = new Set<number>();
  let current = pid;
  while (current > 1) {
    ancestors.add(current);
    try {
      const stat = await Bun.file(`/proc/${current}/stat`).text();
      // Format: pid (comm) state ppid ...
      // comm can contain spaces/parens, so find the last ')' first
      const lastParen = stat.lastIndexOf(")");
      const fields = stat.slice(lastParen + 2).split(" ");
      const ppid = parseInt(fields[1], 10);
      if (isNaN(ppid) || ppid <= 1) break;
      current = ppid;
    } catch {
      break;
    }
  }
  return ancestors;
}

/**
 * Find the niri window ID for the terminal running this opencode instance.
 * Walks our process tree upward and matches against niri window PIDs.
 */
async function findOurWindowId(): Promise<number | null> {
  if (cachedWindowId !== null) return cachedWindowId;
  try {
    const ancestors = await getAncestorPids(process.pid);
    const proc = Bun.spawn([NIRI_MSG, "msg", "--json", "windows"], {
      stdout: "pipe",
      stderr: "pipe",
    });
    const output = await new Response(proc.stdout).text();
    await proc.exited;
    const windows: Array<{ id: number; pid: number }> = JSON.parse(output);
    for (const win of windows) {
      if (ancestors.has(win.pid)) {
        cachedWindowId = win.id;
        return cachedWindowId;
      }
    }
  } catch (e) {
    console.error("[opencode-notify] Failed to find niri window:", e);
  }
  return null;
}

/**
 * Check if our terminal window is currently focused in niri.
 */
async function isWindowFocused(): Promise<boolean> {
  try {
    const proc = Bun.spawn([NIRI_MSG, "msg", "--json", "focused-window"], {
      stdout: "pipe",
      stderr: "pipe",
    });
    const output = await new Response(proc.stdout).text();
    await proc.exited;
    if (!output.trim()) return false;
    const focused: { id: number } = JSON.parse(output);
    const ourId = await findOurWindowId();
    return ourId !== null && focused.id === ourId;
  } catch {
    return false;
  }
}

/**
 * Focus our terminal window in niri.
 */
async function focusWindow(): Promise<void> {
  const windowId = await findOurWindowId();
  if (windowId === null) return;
  const proc = Bun.spawn(
    [NIRI_MSG, "msg", "action", "focus-window", "--id", String(windowId)],
    { stdout: "pipe", stderr: "pipe" },
  );
  await proc.exited;
}

/**
 * Send a notification with optional actions. Returns the action name clicked,
 * or empty string if dismissed/expired.
 */
async function sendNotification(
  title: string,
  body: string,
  actions: [string, string][] = [],
  wait = false,
  timeoutMs = 0,
): Promise<string> {
  const args: string[] = [
    NOTIFY_SEND,
    "--app-name=opencode",
    "--icon=terminal",
  ];

  if (wait || actions.length > 0) {
    args.push("--wait");
  }

  if (timeoutMs > 0) {
    args.push(`--expire-time=${timeoutMs}`);
  }

  for (const [name, label] of actions) {
    args.push(`--action=${name}=${label}`);
  }

  args.push(title, body);

  const proc = Bun.spawn(args, { stdout: "pipe", stderr: "pipe" });
  const stdout = await new Response(proc.stdout).text();
  await proc.exited;

  return stdout.trim();
}

/**
 * Send a notification and handle the "show" action (focus window).
 * Fire-and-forget: runs in the background.
 */
function notifyWithShow(title: string, body: string): void {
  (async () => {
    try {
      const action = await sendNotification(
        title,
        body,
        [["show", "Show"]],
        true,
        30_000,
      );
      if (action === "show") {
        await focusWindow();
      }
    } catch (e) {
      console.error("[opencode-notify] Notification error:", e);
    }
  })();
}

// Debounce timer for session.idle notifications.
// session.idle fires on every LLM turn, including transient ones where
// the agent immediately continues. We only notify after the session has
// been idle for IDLE_DEBOUNCE_MS without going busy again.
const IDLE_DEBOUNCE_MS = 2000;
let idleTimer: ReturnType<typeof setTimeout> | null = null;

function cancelIdleTimer(): void {
  if (idleTimer !== null) {
    clearTimeout(idleTimer);
    idleTimer = null;
  }
}

const plugin: Plugin = async ({ client }) => {
  return {
    event: async ({ event }) => {
      // Cancel pending idle notification whenever the session becomes busy
      if (event.type === "session.status") {
        const status = (event as any).properties?.status;
        if (status?.type === "busy") {
          cancelIdleTimer();
        }
      }

      // Debounced notification on session idle
      if (event.type === "session.idle") {
        cancelIdleTimer();
        idleTimer = setTimeout(async () => {
          idleTimer = null;
          if (await isWindowFocused()) return;
          notifyWithShow("OpenCode", "Task complete \u2014 input needed");
        }, IDLE_DEBOUNCE_MS);
      }

      // Notification on session error
      if (event.type === "session.error") {
        cancelIdleTimer();
        if (await isWindowFocused()) return;
        notifyWithShow("OpenCode", "An error occurred");
      }

      // Notification when opencode asks the user a question
      if (event.type === "question.asked") {
        if (await isWindowFocused()) return;
        const props = (event as any).properties as {
          questions?: Array<{ question?: string; header?: string }>;
        };
        const firstQ = props?.questions?.[0];
        const body =
          firstQ?.question ??
          firstQ?.header ??
          "A question needs your answer";
        notifyWithShow("OpenCode \u2014 Question", body);
      }

      // Permission requested — show notification with Allow/Deny/Show actions.
      // Uses the SDK client to respond programmatically.
      if (event.type === "permission.asked") {
        if (await isWindowFocused()) return;

        const props = (event as any).properties as {
          id?: string;
          sessionID?: string;
          permission?: string;
          patterns?: string[];
          metadata?: Record<string, unknown>;
        };

        const permType = props.permission ?? "unknown";
        const patterns = props.patterns?.join(", ") ?? "";
        const body = patterns
          ? `[${permType}] ${patterns}`
          : `[${permType}]`;

        // Fire-and-forget: notification runs in the background
        (async () => {
          try {
            const action = await sendNotification(
              "OpenCode \u2014 Permission",
              body,
              [
                ["allow", "Allow"],
                ["always", "Always Allow"],
                ["deny", "Deny"],
                ["show", "Show"],
              ],
              true,
              120_000,
            );

            const sessionID = props.sessionID;
            const permissionID = props.id;

            if (!sessionID || !permissionID) return;

            // SDK method: POST /session/{id}/permissions/{permissionID}
            const respond = (response: string) =>
              client.postSessionIdPermissionsPermissionId({
                path: { id: sessionID, permissionID },
                body: { response },
              });

            switch (action) {
              case "allow":
                await respond("once");
                break;
              case "always":
                await respond("always");
                break;
              case "deny":
                await respond("reject");
                break;
              case "show":
                await focusWindow();
                break;
              default:
                // Dismissed or expired — user handles in TUI
                break;
            }
          } catch (e) {
            // Permission may have already been handled via TUI — that's fine
            console.error("[opencode-notify] Permission notification error:", e);
          }
        })();
      }
    },
  };
};

export default plugin;
