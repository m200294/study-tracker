# Exam Study System

An AI-powered exam preparation system built with Claude, Next.js, Supabase, and Vercel. Designed for structured, data-driven studying with real-time progress tracking and honest performance assessment.

Built for 3 university exams (Algorithms & Data Structures II, How Computers Work, Programming with Data) over a 3-week sprint in March 2026.

---

## How It Works

The system has four parts: **skills**, **tracker**, **coach**, and **MCP automation**. They form a closed loop.

### 1. Skills (Claude Project Skills)

Five custom instruction files that live inside a Claude project. They tell Claude exactly how to run each type of study session:

- **ads2-exam-practice** — Drills past paper questions for Algorithms & Data Structures II. Real exam questions with structured feedback, mark allocation, and weak area diagnosis.
- **pwd-exam-practice** — Same format for Programming with Data. Covers SQL, data types, web scraping, visualisation, EDA.
- **hcw-exam-practice** — Generates fresh exam-style questions on the fly for How Computers Work. MCQs, long answers, and 16-mark scenario questions.
- **deep-encoding** — Guided concept learning sessions using Layers of Learning and Bloom's Revised Taxonomy. Not a lecture — a structured dialogue where the student builds understanding layer by layer.
- **study-coach** — Fetches live session data from the database and generates a brutally honest progress report: pace, accuracy trends, topic coverage gaps, risk scores, trajectory predictions, and a specific 3-day action plan.

### 2. Tracker (This Web App)

A live dashboard that visualises all study session data. Shows per-subject stats, topic coverage heatmaps, accuracy breakdowns, progress charts, recurring weak areas, and days until each exam.

### 3. Coach

When you say "coach check" in any chat, Claude fetches your live session data from Supabase, computes metrics across all subjects, and generates a report. It flags stalled subjects, identifies undertrained topics, predicts where you'll be on exam day at your current pace, and tells you exactly what to study next.

### 4. MCP Automation (New)

An MCP server registered in Claude Desktop that exposes a `save_study_session` tool. At the end of every study session, Claude calls this tool to save results directly to the tracker — no manual JSON copying or pasting required.

### The Loop

```
Study with Claude → Claude auto-saves session via MCP → tracker updates → coach reads tracker → tells you what to study next → repeat
```

No manual file management. No copy-pasting JSON. No data loss between chats.

---

## Stack

- **Frontend**: Next.js 14 (React 18)
- **Styling**: Tailwind CSS v3
- **Database**: Supabase (Postgres)
- **Hosting**: Vercel (free tier)
- **AI**: Claude Desktop with custom project skills + MCP
- **Charts**: Recharts (progress over time)
- **Notifications**: react-hot-toast
- **Cost**: $0 (all free tiers)

---

## Setup (20 minutes)

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) → Sign up (free)
2. Click **New Project** → pick a name and password → Create
3. Wait ~2 min for it to spin up

### 2. Create the Database Table

1. In your Supabase dashboard → **SQL Editor** (left sidebar)
2. Click **New Query**
3. Copy the entire contents of `supabase-schema.sql` and paste it in
4. Click **Run** — you should see "Success"

### 3. Get Your API Keys

1. In Supabase → **Settings** (gear icon) → **API**
2. Copy the **Project URL** (looks like `https://xyz.supabase.co`)
3. Copy the **anon public** key (long string starting with `eyJ...`)

### 4. Deploy to Vercel

1. Push this folder to a GitHub repo
2. Go to [vercel.com](https://vercel.com) → Sign up → **Import** your repo
3. Add **Environment Variables**:
   - `NEXT_PUBLIC_SUPABASE_URL` = your Project URL
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = your anon key
   - `SESSION_API_KEY` = a random secret (generate with `openssl rand -hex 32`)
4. Set **Root Directory** to the folder containing `package.json` if nested
5. Set **Framework Preset** to Next.js
6. Click **Deploy** — live URL in ~60 seconds

### 5. Set Up Claude Desktop MCP

1. Install MCP server dependencies:
   ```bash
   cd mcp-server
   npm install
   ```

2. Open your Claude Desktop config file:
   - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

3. Add the MCP server entry:
   ```json
   {
     "mcpServers": {
       "study-tracker": {
         "command": "node",
         "args": ["/path/to/mcp-server/index.js"],
         "env": {
           "TRACKER_API_URL": "https://your-app.vercel.app/api/sessions",
           "TRACKER_API_KEY": "your-SESSION_API_KEY-value"
         }
       }
     }
   }
   ```

4. Restart Claude Desktop — you should see "study-tracker" in the MCP tools list.

See `mcp-server/README.md` for detailed instructions.

### 6. Set Up Claude Project

1. Create a Claude project
2. Add the 5 skill files to the project's custom skills
3. Update exam practice skills to say: "Use the `save_study_session` tool to save session results automatically"
4. Start studying

### Alternative: Run Locally

```bash
npm install
cp .env.local.example .env.local
# Edit .env.local with your Supabase keys
npm run dev
```

---

## Usage

### Adding Sessions

There are three ways to add sessions:

- **Automatic (MCP)**: Claude calls `save_study_session` at the end of a study session. No action needed from you.
- **Paste JSON**: Click `+ Add Session` → **Paste JSON** tab → paste Claude's output → Add.
- **Manual form**: Click `+ Add Session` → **Use Form** tab → fill in fields.

### API Endpoint

Sessions can also be added programmatically via the API:

```bash
curl -X POST https://your-app.vercel.app/api/sessions \
  -H "Content-Type: application/json" \
  -H "x-api-key: your-secret-key" \
  -d '{
    "subject": "ADS2",
    "type": "exam_practice",
    "topics": ["BST", "Graphs"],
    "attempted": 10,
    "correct": 8,
    "partial": 1,
    "wrong": 1,
    "estimated_marks": "30/40",
    "weak_areas": ["BST deletion edge cases"],
    "next_session": "Graph traversal algorithms"
  }'
```

### Session JSON Format

Exam practice:
```json
{
  "subject": "ADS2",
  "type": "exam_practice",
  "topics": ["BST", "Graphs"],
  "attempted": 10,
  "correct": 8,
  "partial": 1,
  "wrong": 1,
  "estimated_marks": "30/40",
  "weak_areas": ["BST deletion edge cases"],
  "next_session": "Graph traversal algorithms",
  "topic_breakdown": {
    "BST": { "attempted": 6, "correct": 5, "partial": 0, "wrong": 1 },
    "Graphs": { "attempted": 4, "correct": 3, "partial": 1, "wrong": 0 }
  }
}
```

Deep encoding:
```json
{
  "subject": "PWD",
  "type": "deep_encoding",
  "topics": ["SQL"],
  "duration_mins": 40,
  "bloom_level_reached": 4,
  "concepts_encoded": ["Joins", "Subqueries", "Aggregation"],
  "weak_areas": ["Complex JOINs"],
  "next_session": "Practice SQL exam questions"
}
```

---

## File Structure

```
study-tracker-app/
├── app/
│   ├── api/
│   │   └── sessions/
│   │       └── route.js          # POST endpoint for automated session saving
│   ├── layout.js                 # Root layout with Toaster provider
│   ├── page.js                   # Entry point
│   └── globals.css               # Tailwind directives + base styles
├── components/
│   ├── StudyTracker.jsx          # Main shell (tabs, state, data loading)
│   ├── AppHeader.jsx             # Header bar with title + add button
│   ├── OverviewPanel.jsx         # Overview cards + weak areas
│   ├── SubjectDashboard.jsx      # Per-subject view (stats, weak areas, log)
│   ├── SessionCard.jsx           # Individual session card (expandable)
│   ├── TopicHeatmap.jsx          # Topic coverage bars
│   ├── AddSessionModal.jsx       # Add/edit session modal (JSON + form)
│   └── ProgressChart.jsx         # Accuracy over time line chart
├── lib/
│   ├── supabase.js               # DB client + CRUD operations
│   ├── subjects.js               # Subject config + helper functions
│   └── session-utils.js          # Aggregation and calculation helpers
├── mcp-server/
│   ├── index.js                  # MCP server with save_study_session tool
│   ├── package.json              # MCP server dependencies
│   └── README.md                 # Claude Desktop setup guide
├── tailwind.config.js            # Tailwind config with custom theme
├── postcss.config.js             # PostCSS config
├── supabase-schema.sql           # Run once in Supabase SQL Editor
├── .env.local.example            # Template for env vars
├── next.config.js
├── PLAN.md                       # Upgrade roadmap
└── package.json
```

---

## Adapting This for Your Own Exams

This system isn't specific to these 3 subjects. To adapt it:

1. **Edit the `SUBJECTS` config** in `lib/subjects.js` — change names, topics, exam dates, colours
2. **Write your own skill files** — use the existing ones as templates. The structure is: exam context → topic priority → question bank → feedback protocol → session save format
3. **Update the SQL schema** — change the `CHECK` constraint on the `subject` column to match your subjects
4. **Update the API route** — update the valid subjects list in `app/api/sessions/route.js`
5. **Update the MCP server** — update the subject enum in `mcp-server/index.js`
6. **Update project instructions** — paste your Supabase keys and subject list

The core loop (skill → session → tracker → coach → repeat) works for any exam-based studying.
