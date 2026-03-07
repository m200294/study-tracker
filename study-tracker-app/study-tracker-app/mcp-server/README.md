# Study Tracker MCP Server

This MCP server exposes a single tool, `save_study_session`, so Claude Desktop can write study sessions directly into the Study Tracker app through the `/api/sessions` endpoint.

## Prerequisites

- Node.js 18+
- A running or deployed Study Tracker app
- `SESSION_API_KEY` configured in the Next.js app if you want API-key protection

## Install

From this directory:

```bash
npm install
```

## Environment

The server reads these environment variables:

- `TRACKER_API_URL`: Full URL to the API route, for example `https://your-app.vercel.app/api/sessions`
- `TRACKER_API_KEY`: Optional. Must match `SESSION_API_KEY` in the app when API-key protection is enabled.

## Claude Desktop Config

Add a server entry to your Claude Desktop config file.

macOS:
- `~/Library/Application Support/Claude/claude_desktop_config.json`

Windows:
- `%APPDATA%\\Claude\\claude_desktop_config.json`

Example:

```json
{
  "mcpServers": {
    "study-tracker": {
      "command": "node",
      "args": [
        "/absolute/path/to/study-tracker-app/mcp-server/index.js"
      ],
      "env": {
        "TRACKER_API_URL": "https://your-app.vercel.app/api/sessions",
        "TRACKER_API_KEY": "your-secret-key"
      }
    }
  }
}
```

## Tool

`save_study_session` accepts:

- `subject`: `ADS2` | `PWD` | `HCW`
- `type`: `exam_practice` | `deep_encoding`
- `topics`: string array
- `attempted`, `correct`, `partial`, `wrong`: numbers
- `estimated_marks`: string
- `weak_areas`: string array
- `next_session`: string
- `topic_breakdown`: object keyed by topic
- `duration_mins`: number
- `bloom_level_reached`: number
- `concepts_encoded`: string array

## Example Use In Claude

Ask Claude to save a session directly, for example:

```text
Save a study session for ADS2 exam practice: 12 attempted, 9 correct, 2 partial, 1 wrong, weak areas BST deletion and graph traversal, next session focus shortest-path questions.
```

Claude can then call `save_study_session` instead of producing JSON for manual copy-paste.
