# Study Tracker — Web App

Live exam study tracker with persistent database. No more file swapping.

**Stack:** Next.js + Supabase (Postgres) + Vercel — all free tier.

---

## Setup (15 minutes)

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) → Sign up (free)
2. Click **New Project** → pick a name and password → Create
3. Wait ~2 min for it to spin up

### 2. Create the Database Table

1. In your Supabase dashboard → **SQL Editor** (left sidebar)
2. Click **New Query**
3. Copy the entire contents of `supabase-schema.sql` and paste it in
4. Click **Run** — you should see "Success"
5. This creates the `sessions` table and seeds your existing session data

### 3. Get Your API Keys

1. In Supabase → **Settings** (gear icon) → **API**
2. Copy the **Project URL** (looks like `https://xyz.supabase.co`)
3. Copy the **anon public** key (long string starting with `eyJ...`)

### 4. Deploy to Vercel

1. Push this folder to a GitHub repo (or use Vercel CLI)
2. Go to [vercel.com](https://vercel.com) → Sign up → **Import** your repo
3. In the deployment settings, add **Environment Variables**:
   - `NEXT_PUBLIC_SUPABASE_URL` = your Project URL
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = your anon key
4. Click **Deploy**
5. Done — you'll get a live URL like `study-tracker-xxx.vercel.app`

### Alternative: Run Locally

```bash
cd study-tracker-app
npm install

# Create .env.local with your Supabase keys
cp .env.local.example .env.local
# Edit .env.local with your actual keys

npm run dev
# Open http://localhost:3000
```

---

## Usage

- **Add Session**: Click the `+ Add Session` button in the header
  - **Paste JSON**: Paste session JSON directly (same format Claude generates)
  - **Use Form**: Fill in fields manually
- **Delete Session**: Expand any session card → click "Delete Session"
- **Data persists forever** in Supabase — no file management needed

### JSON Format (for pasting)

```json
{
  "subject": "ADS2",
  "type": "exam_practice",
  "topics": ["BST", "Graphs"],
  "attempted": 10,
  "correct": 8,
  "partial": 1,
  "wrong": 1,
  "estimatedMarks": "30/40",
  "weakAreas": ["BST deletion edge cases"],
  "nextSession": "Graph traversal algorithms"
}
```

For deep encoding sessions:

```json
{
  "subject": "PWD",
  "type": "deep_encoding",
  "topics": ["SQL"],
  "duration_mins": 40,
  "bloom_level_reached": 4,
  "concepts_encoded": ["Joins", "Subqueries", "Aggregation"],
  "weakAreas": ["Complex JOINs"],
  "nextSession": "Practice SQL exam questions"
}
```

---

## File Structure

```
study-tracker-app/
├── app/
│   ├── layout.js          # Root layout
│   ├── page.js            # Entry point
│   └── globals.css         # Base styles
├── components/
│   └── StudyTracker.jsx    # Main UI (all components)
├── lib/
│   └── supabase.js         # DB client + operations
├── supabase-schema.sql     # Run once in Supabase SQL Editor
├── .env.local.example      # Template for env vars
├── next.config.js
└── package.json
```
