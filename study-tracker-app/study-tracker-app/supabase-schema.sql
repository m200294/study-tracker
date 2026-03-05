-- ═══════════════════════════════════════════════════════
-- STUDY TRACKER — Supabase Schema
-- Run this in your Supabase SQL Editor (one time setup)
-- ═══════════════════════════════════════════════════════

CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  subject TEXT NOT NULL CHECK (subject IN ('ADS2', 'PWD', 'HCW')),
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  type TEXT NOT NULL DEFAULT 'exam_practice' CHECK (type IN ('exam_practice', 'deep_encoding')),
  topics JSONB DEFAULT '[]',
  topic TEXT,
  attempted INT DEFAULT 0,
  correct INT DEFAULT 0,
  partial INT DEFAULT 0,
  wrong INT DEFAULT 0,
  estimated_marks TEXT,
  topic_breakdown JSONB,
  duration_mins INT,
  bloom_level_reached INT,
  layers_covered JSONB,
  concepts_encoded JSONB,
  weak_areas JSONB DEFAULT '[]',
  next_session TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast subject filtering
CREATE INDEX idx_sessions_subject ON sessions(subject);
CREATE INDEX idx_sessions_timestamp ON sessions(timestamp DESC);

-- Enable Row Level Security (optional — for single-user this is fine open)
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- Allow all operations (single user app, no auth needed)
CREATE POLICY "Allow all" ON sessions FOR ALL USING (true) WITH CHECK (true);

-- ═══════════════════════════════════════════════════════
-- SEED DATA — your existing sessions
-- ═══════════════════════════════════════════════════════

INSERT INTO sessions (id, subject, timestamp, type, topics, topic, attempted, correct, partial, wrong, estimated_marks, topic_breakdown, duration_mins, bloom_level_reached, layers_covered, concepts_encoded, weak_areas, next_session)
VALUES (
  'pwd_sql_encoding_001',
  'PWD',
  '2026-03-05T00:00:00.000Z',
  'deep_encoding',
  '["SQL"]',
  'SQL & Databases',
  0, 0, 0, 0,
  '',
  NULL,
  40,
  4,
  '[1, 2, 3]',
  '["Relational model", "Normalization", "Data integrity (keys)", "SELECT query structure", "Python sqlite3 four-step pattern", "Error handling with sqlite3"]',
  '["SQL query syntax (WHERE, ORDER BY, GROUP BY, aggregates)", "Primary key vs foreign key distinction", "Writing queries from scratch — procedural gap"]',
  'SQL query syntax → then PWD exam practice on SQL questions'
);

INSERT INTO sessions (id, subject, timestamp, type, topics, attempted, correct, partial, wrong, estimated_marks, topic_breakdown, weak_areas, next_session)
VALUES (
  'hcw-1741042800000',
  'HCW',
  '2026-03-04T00:00:00.000Z',
  'exam_practice',
  '["CPU & Architecture", "Data Representation", "Networking", "Operating Systems", "Machine Learning"]',
  9, 8, 0, 1,
  '32/36',
  '{"CPU & Architecture": {"attempted": 2, "correct": 2, "partial": 0, "wrong": 0}, "Data Representation": {"attempted": 2, "correct": 2, "partial": 0, "wrong": 0}, "Networking": {"attempted": 2, "correct": 1, "partial": 0, "wrong": 1}, "Operating Systems": {"attempted": 1, "correct": 1, "partial": 0, "wrong": 0}, "Machine Learning": {"attempted": 2, "correct": 2, "partial": 0, "wrong": 0}}',
  '["URL structure: path vs domain confusion", "Deadlock: not yet studied"]',
  'Deadlock (4 conditions + resolution)'
);
