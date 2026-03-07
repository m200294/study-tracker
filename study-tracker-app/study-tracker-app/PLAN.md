# PLAN v2: Study Tracker Upgrades

## Goal
Upgrade an existing exam study tracker with mobile responsiveness, better UX feedback, session editing, a progress-over-time chart, and automated session saving via MCP — eliminating manual JSON copy-paste from the study workflow.

## Tech Stack
- Language: JavaScript (React/JSX, Node.js)
- Framework: Next.js 14 (App Router)
- Database: Supabase (Postgres)
- Styling: Tailwind CSS v3 (migrating from inline styles)
- Key dependencies:
  - `tailwindcss@3` + `postcss` + `autoprefixer` (styling)
  - `recharts` (progress chart)
  - `react-hot-toast` (toast notifications)
  - `@modelcontextprotocol/sdk` (MCP server for Claude Desktop)

## Architecture Overview
This is an upgrade to an existing single-page Next.js app. The current app lives entirely in one 740-line component (`StudyTracker.jsx`) with all inline styles. The plan migrates styling to Tailwind CSS for responsiveness, splits the monolith into focused component files, adds an edit flow that reuses the existing add-session modal, introduces toast notifications via react-hot-toast, adds a recharts-powered progress chart to the overview panel, and — critically — adds a Next.js API route + MCP server so Claude Desktop can save sessions automatically without manual JSON copy-paste. The Supabase layer gets two new functions (`updateSession`, and the API route reuses `addSession`). The MCP server is a standalone Node.js process registered in Claude Desktop's config.

## File Structure
```
study-tracker-app/
├── app/
│   ├── api/
│   │   └── sessions/
│   │       └── route.js         # NEW: POST endpoint for automated session saving
│   ├── layout.js                # Add Toaster provider + Google Fonts link
│   ├── page.js                  # Unchanged
│   └── globals.css              # Tailwind directives + custom theme vars
├── components/
│   ├── StudyTracker.jsx         # Main shell (tabs, state, data loading) — Tailwind
│   ├── OverviewPanel.jsx        # Overview cards + weak areas — extracted & Tailwind
│   ├── SubjectDashboard.jsx     # Per-subject view — extracted & Tailwind
│   ├── SessionCard.jsx          # Individual session card — extracted & Tailwind
│   ├── TopicHeatmap.jsx         # Topic coverage bars — extracted & Tailwind
│   ├── AddSessionModal.jsx      # Add/Edit modal (reused for both) — extracted & Tailwind
│   └── ProgressChart.jsx        # NEW: recharts line chart
├── lib/
│   ├── supabase.js              # Add updateSession function
│   └── subjects.js              # NEW: extracted SUBJECTS config + helpers
├── mcp-server/
│   ├── package.json             # NEW: MCP server dependencies
│   ├── index.js                 # NEW: MCP server with save_study_session tool
│   └── README.md                # NEW: Setup instructions for Claude Desktop
├── tailwind.config.js
├── postcss.config.js
├── supabase-schema.sql          # Unchanged
├── .gitignore
└── package.json
```

## Build Order

### Chunk 1: Cleanup + Tailwind installation ✅ DONE
- **Status:** Complete. Tailwind v3.4.19, recharts 3.8.0, react-hot-toast 2.6.0 installed. Zone.Identifier files deleted. .gitignore updated. .env.local configured.

### Chunk 2: Extract components from StudyTracker.jsx
- **Goal:** The 740-line monolith is split into separate files. The app works identically to before — no visual or behavioral changes.
- **Delegated to: ChatGPT/Codex** (mechanical refactor, no design decisions)
- **Files:** Create `lib/subjects.js`, `components/OverviewPanel.jsx`, `components/SubjectDashboard.jsx`, `components/SessionCard.jsx`, `components/TopicHeatmap.jsx`, `components/AddSessionModal.jsx`. Modify `components/StudyTracker.jsx`.
- **Done when:** The app renders and behaves exactly as before (add session, delete session, switch tabs, expand cards all work), but `StudyTracker.jsx` is under 120 lines and imports the other components.
- **Implementation notes:**
  - Create `lib/subjects.js` containing: the `SUBJECTS` config object, the `daysUntil()` function, and the `aggregateTopics()` function. Export all three.
  - Move each function component into its own file as a default export. Each file imports what it needs from `lib/subjects.js`.
  - `StatBox` is small and only used in `SubjectDashboard` — keep it in that file as a local component.
  - Keep all styles as inline for now — conversion happens in Chunks 3-4.
  - Test every feature after extraction: tab switching, session expand/collapse, add via JSON, add via form, delete.
  - Import chain: `StudyTracker.jsx` imports `OverviewPanel`, `SubjectDashboard`, `AddSessionModal`. `SubjectDashboard` imports `SessionCard`, `TopicHeatmap`. All import from `lib/subjects.js`.

### Chunk 3: Migrate inline styles to Tailwind CSS (core shell + overview)
- **Goal:** `StudyTracker.jsx` (the main shell with header/tabs) and `OverviewPanel.jsx` are fully converted from inline styles to Tailwind classes, including responsive breakpoints for the overview grid.
- **Delegated to: ChatGPT/Codex** (mechanical conversion, patterns defined below)
- **Files:** `components/StudyTracker.jsx`, `components/OverviewPanel.jsx`, `tailwind.config.js`
- **Done when:** The overview grid displays as 3 columns on desktop (`md:grid-cols-3`), 2 columns on tablet (`sm:grid-cols-2`), and 1 column on mobile (default `grid-cols-1`). All inline `style={}` attributes are removed from these two files.
- **Implementation notes:**
  - Custom colors are already in `tailwind.config.js` under `extend.colors`.
  - For dynamic accent colors from `SUBJECTS[x].accent`, keep a small inline `style` for `borderColor`/`color` since Tailwind can't do dynamic values. Use Tailwind for everything else.
  - Key responsive conversions:
    - Overview grid: `grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3.5`
    - Header: stack vertically on mobile with `flex-col sm:flex-row`
    - Tab bar: horizontally scrollable on mobile with `overflow-x-auto`
  - Use arbitrary values where needed: `p-[18px_28px]` or closest Tailwind equivalent.

### Chunk 4: Migrate remaining components to Tailwind CSS
- **Goal:** `SubjectDashboard.jsx`, `SessionCard.jsx`, `TopicHeatmap.jsx`, and `AddSessionModal.jsx` are all converted to Tailwind. The entire app is now responsive.
- **Delegated to: ChatGPT/Codex** (same mechanical conversion pattern as Chunk 3)
- **Files:** `components/SubjectDashboard.jsx`, `components/SessionCard.jsx`, `components/TopicHeatmap.jsx`, `components/AddSessionModal.jsx`
- **Done when:** Zero `style={}` attributes remain except for dynamic color values and conic-gradient. Modal is usable on mobile. Session cards readable on small screens.
- **Implementation notes:**
  - `SessionCard.jsx`: The circular progress indicator uses `conic-gradient` — must stay inline. Everything else converts.
  - `TopicHeatmap.jsx`: Bar widths are dynamic percentages — keep `style={{ width: \`${pct}%\` }}` inline.
  - `AddSessionModal.jsx`: Use `fixed inset-0` for overlay, `w-full max-w-xl mx-auto` for body. Mobile: `max-h-[90vh] m-4 sm:m-auto`.
  - Replace `onMouseEnter`/`onMouseLeave` with Tailwind `hover:border-[#444]`.

### Chunk 5: API route for automated session saving
- **Goal:** A public POST endpoint exists at `/api/sessions` that accepts session JSON and inserts it into Supabase. This is the backend for the MCP automation.
- **Built by: Claude** (critical integration piece)
- **Files:** `app/api/sessions/route.js`
- **Done when:** `curl -X POST https://localhost:3000/api/sessions -H "Content-Type: application/json" -d '{"subject":"ADS2","type":"exam_practice","attempted":5,"correct":4,"partial":1,"wrong":0}'` returns 200 with the created session, and the session appears in the tracker dashboard.
- **Implementation notes:**
  - Use Next.js App Router route handler format: `export async function POST(request) { ... }`
  - Parse the JSON body, validate `subject` is one of ADS2/PWD/HCW, call the existing `addSession()` from `lib/supabase.js`
  - Return `NextResponse.json({ success: true, session })` on success
  - Return `NextResponse.json({ error: message }, { status: 400 })` on validation failure
  - Return `NextResponse.json({ error: message }, { status: 500 })` on Supabase error
  - Add a simple API key check via `x-api-key` header matched against a `SESSION_API_KEY` env var — prevents random people from posting to the endpoint. If no env var is set, skip the check (for local dev).

### Chunk 6: MCP server for Claude Desktop
- **Goal:** A working MCP server that Claude Desktop can use. Exposes a `save_study_session` tool that POSTs session data to the API route. After registering it, Claude can save sessions automatically at the end of every study session.
- **Built by: Claude** (requires MCP protocol knowledge)
- **Files:** `mcp-server/package.json`, `mcp-server/index.js`, `mcp-server/README.md`
- **Done when:** The MCP server is registered in Claude Desktop config, Claude Desktop shows `save_study_session` as an available tool, and calling it successfully creates a session in Supabase.
- **Implementation notes:**
  - Use `@modelcontextprotocol/sdk` for the MCP server
  - The `save_study_session` tool accepts parameters: `subject` (enum: ADS2/PWD/HCW), `type` (enum: exam_practice/deep_encoding), `topics` (array of strings), `attempted` (number), `correct` (number), `partial` (number), `wrong` (number), `estimated_marks` (string), `weak_areas` (array of strings), `next_session` (string), `topic_breakdown` (object), `duration_mins` (number), `bloom_level_reached` (number), `concepts_encoded` (array of strings)
  - The tool POSTs to the configured API URL (env var `TRACKER_API_URL`)
  - Include the API key in the `x-api-key` header (env var `TRACKER_API_KEY`)
  - README.md includes: how to install deps, how to add to `claude_desktop_config.json`, example config block, and example of how Claude uses the tool
  - Claude Desktop config entry:
    ```json
    {
      "mcpServers": {
        "study-tracker": {
          "command": "node",
          "args": ["/absolute/path/to/mcp-server/index.js"],
          "env": {
            "TRACKER_API_URL": "https://your-app.vercel.app/api/sessions",
            "TRACKER_API_KEY": "your-secret-key"
          }
        }
      }
    }
    ```

### Chunk 7: Toast notifications
- **Goal:** Users see a success toast when a session is added or deleted, and an error toast if either operation fails.
- **Delegated to: ChatGPT/Codex** (simple integration, pattern provided)
- **Files:** `app/layout.js`, `components/StudyTracker.jsx`
- **Done when:** Adding a session shows a green "Session added" toast that auto-dismisses after 3 seconds. Deleting shows "Session deleted". Errors show red toast.
- **Implementation notes:**
  - In `layout.js`, add `<Toaster position="top-right" />` inside `<body>` (import from `react-hot-toast`)
  - In `StudyTracker.jsx`, wrap `handleAdd` and `handleDelete` in try/catch, call `toast.success(...)` or `toast.error(...)`
  - Style toaster to match dark theme:
    ```jsx
    <Toaster position="top-right" toastOptions={{
      style: { background: '#1a1a1a', color: '#e0e0e0', border: '1px solid #333', fontFamily: 'JetBrains Mono, monospace', fontSize: '13px' },
      success: { iconTheme: { primary: '#4ecdc4', secondary: '#000' } },
      error: { iconTheme: { primary: '#ff6b6b', secondary: '#000' } },
    }} />
    ```

### Chunk 8: Session editing (updateSession + edit mode on modal)
- **Goal:** Users can click "Edit" on any expanded session card to edit it in-place.
- **Delegated to: ChatGPT/Codex** (pattern provided, builds on extracted components)
- **Files:** `lib/supabase.js`, `components/StudyTracker.jsx`, `components/AddSessionModal.jsx`, `components/SessionCard.jsx`
- **Done when:** Clicking "Edit" opens the modal pre-filled. Saving updates Supabase. Toast shows "Session updated".
- **Implementation notes:**
  - Add `updateSession(id, updates)` to `lib/supabase.js` — same field mapping as `addSession` but uses `.update().eq("id", id)`
  - In `StudyTracker.jsx`, add `editingSession` state. Pass `onEdit` callback to `SessionCard`.
  - `AddSessionModal` accepts optional `editSession` prop. If present: default to form mode, pre-fill fields via `useEffect`, button says "Save Changes", submit calls `onUpdate` instead of `onAdd`.
  - Add "Edit" button next to "Delete Session" in `SessionCard`. Hide JSON tab in edit mode.

### Chunk 9: Progress chart over time
- **Goal:** A line chart in the Overview panel shows accuracy % per subject over time.
- **Delegated to: ChatGPT/Codex** (self-contained component, data logic provided)
- **Files:** `components/ProgressChart.jsx` (new), `components/OverviewPanel.jsx`
- **Done when:** Overview tab shows a line chart with one colored line per subject. Hovering shows date + accuracy. Responsive on mobile.
- **Implementation notes:**
  - Create `components/ProgressChart.jsx` receiving `allSessions` prop
  - Data transform: for each exam_practice session sorted by timestamp, compute running cumulative accuracy per subject. Output: `[{ date: "4 Mar", ADS2: 85, PWD: null, HCW: 89 }, ...]`
  - Use recharts: `ResponsiveContainer` (height 280), `LineChart`, three `Line` elements with subject accent colors, `connectNulls={true}`, `CartesianGrid` with `stroke="#1e1e1e"`, `YAxis domain={[0,100]}`
  - Dark-themed tooltip
  - If fewer than 2 exam_practice sessions total, show placeholder text instead of empty chart
  - Render between subject cards and weak areas section in `OverviewPanel`

## Delegation Summary

| Chunk | Owner | Reason |
|-------|-------|--------|
| 1 | Claude | ✅ Done |
| 2 | ChatGPT/Codex | Mechanical file extraction, no design decisions |
| 3 | ChatGPT/Codex | Mechanical style conversion, patterns defined |
| 4 | ChatGPT/Codex | Same pattern as Chunk 3 |
| 5 | **Claude** | Critical backend integration, security |
| 6 | **Claude** | MCP protocol expertise required |
| 7 | ChatGPT/Codex | Simple integration, copy-paste pattern |
| 8 | ChatGPT/Codex | Pattern fully specified |
| 9 | ChatGPT/Codex | Self-contained, data logic provided |

## Decisions & Tradeoffs

- **Tailwind v3 over v4:** v4 requires Node >= 20, and the project runs on Node 18. v3 is stable and fully featured.
- **API route + MCP over direct Supabase MCP:** Adding an API route in front of Supabase means the MCP server doesn't need Supabase credentials — just the API URL and a simple key. Easier to secure, easier to share, and the API route is reusable for other integrations.
- **Simple x-api-key over full auth:** This is a single-user study app. A shared secret in an env var is sufficient. No need for JWT/OAuth complexity.
- **Tailwind over CSS Modules:** Responsive utilities and rapid iteration. Longer class strings are acceptable for a solo project.
- **react-hot-toast over custom:** 5KB, zero-config, dark theme in one options object.
- **recharts over Chart.js:** React-native composable components vs imperative canvas API.
- **Cumulative accuracy over per-session:** Smoother trend line, less noise from single bad sessions.

## Open Questions

- **API key rotation:** After deploying, generate a random key and set it as `SESSION_API_KEY` in Vercel env vars and `TRACKER_API_KEY` in Claude Desktop config. Consider rotating periodically.
- **Vercel URL:** Once deployed, update the MCP server config with your actual Vercel URL (e.g., `https://study-tracker-abc123.vercel.app`).
- **Claude project skill update:** After the MCP server is working, update your exam practice skill instructions to say "use the save_study_session tool" instead of "output JSON for the user to paste."
