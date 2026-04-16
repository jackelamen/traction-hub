# Traction Hub — Complete Rebuild Specification
### For React.js + Gemini (Google AI Studio)

---

## PART 1: PRODUCT SPECIFICATION (MODEL-AGNOSTIC)

---

### 1.1 Product Overview

**Traction Hub** is a single-user personal productivity and wellness OS built as a web application. It is not a chat interface — the AI model is used in the background for intelligent features (intent parsing, carry-over suggestions, distraction pattern analysis, Notion sync formatting) while the primary UI is a structured dashboard.

**Core philosophy:** Intentional workdays over reactive ones. Every feature exists to help the user plan with purpose, focus deeply, track honestly, and reflect meaningfully.

**Primary use cases:**
1. **Morning ritual** — guided check-in: gratitude, energy level, top 3 priorities, carry-over from yesterday
2. **Deep work management** — countdown timer, session logging, Asana task integration
3. **Time blocking** — visual daily timeline (6 AM–10 PM), drag-and-drop blocks with tasks
4. **Distraction logging** — capture interruptions with category, duration, trigger, and reflection
5. **Ledger of Intent** — pre-work intention capture before opening any content tab
6. **End-of-day reflection** — pillar checklist, mood, win of day, steps, tomorrow's intention
7. **Progress tracking** — 30-day heatmap, streak counter, weekly summary, history table
8. **Notion sync** — push daily logs to a Notion database via API proxy

**Not in scope:** Multi-user, real-time collaboration, mobile-native, AI chat interface.

---

### 1.2 Architecture Overview

```
React SPA (client-only)
├── State: localStorage (all persistence — no backend)
├── External APIs:
│   ├── Asana REST API (task list, task completion)
│   ├── Notion API (via proxy — create/update daily log pages)
│   └── YouTube oEmbed (track title lookup for music player)
├── AI layer (background only):
│   └── Gemini API (distraction analysis, intent suggestions, smart summaries)
└── No user accounts, no server, no database
```

---

### 1.3 Data Schemas

All data is stored in `localStorage` under these keys:

#### `30day-traction-v2` — Daily Logs
```json
{
  "YYYY-MM-DD": {
    "sanctuary": true,
    "ledger": true,
    "noConsume": true,
    "timer": true,
    "horizon": true,
    "walk": true,
    "pillar1": true,
    "pillar2": true,
    "walks": 3,
    "steps": 8540,
    "stepBase": 1200,
    "netSteps": 7340,
    "focusScore": 83,
    "rating": "Strong",
    "notes": "string",
    "win": "string",
    "tomorrow": "string",
    "eodMood": 3,
    "distractCount": 2,
    "distractMinsLost": 15,
    "breathRounds": 2,
    "savedAt": "ISO8601"
  }
}
```

#### `30day-sessions-v1` — Deep Work Sessions
```json
{
  "YYYY-MM-DD": [
    {
      "task": "string",
      "tasks": [{ "gid": "string|null", "name": "string", "status": "done|ongoing" }],
      "dur": 50,
      "focus": "Writing|Coding|Strategy|Research|Design|Reading|Planning|Other",
      "energy": 3,
      "energyLabel": "High",
      "notes": "string",
      "time": "4:06 PM",
      "ts": 1713000000000,
      "asanaGid": "string|null"
    }
  ]
}
```

#### `30day-distract-v1` — Distraction Log
```json
{
  "YYYY-MM-DD": [
    {
      "what": "string",
      "type": "Social Media|Email|Phone|Colleague|Internal|Other",
      "trigger": "string",
      "mins": 5,
      "time": "2:15 PM",
      "ts": 1713000000000
    }
  ]
}
```

#### `30day-ledger-v1` — Ledger of Intent
```json
{
  "YYYY-MM-DD": [
    {
      "text": "string",
      "category": "Learning|Research|Inspiration|Tools|Other|General",
      "time": "10:03 AM",
      "ts": 1713000000000
    }
  ]
}
```

#### `30day-blocks-v1` — Time Blocks
```json
{
  "YYYY-MM-DD": [
    {
      "id": "tb_1713000000_abc1",
      "name": "Deep Work",
      "color": "#4f46e5",
      "start": "09:00",
      "dur": 90,
      "tasks": [
        {
          "id": "tb_1713000001_def2",
          "gid": "asana_gid_or_null",
          "name": "string",
          "dur": 30,
          "priority": false,
          "done": false,
          "blockColor": "#4f46e5"
        }
      ]
    }
  ]
}
```

#### `30day-breath-v1` — Box Breathing Log
```json
{
  "YYYY-MM-DD": [
    { "time": "12:01 PM", "rounds": 1, "secs": 64, "ts": 1713000000000 }
  ]
}
```

#### `morning-setup-v1` — Morning Setup
```json
{
  "date": "YYYY-MM-DD",
  "gratitude": "string",
  "energy": 3,
  "priorities": ["string", "string", "string"]
}
```

#### `30day-tomorrow-v1` — Intention Carry-forward
```json
{ "date": "YYYY-MM-DD", "text": "string" }
```

#### `30day-day-types-v1` — Exempt Days
```json
{ "YYYY-MM-DD": "holiday|sick|travel|ooo" }
```

#### `30day-steps-v1` — Step Tracking State
```json
{
  "date": "YYYY-MM-DD",
  "base": 1200,
  "current": 8540,
  "goal": 10000
}
```

#### `30day-tracks-v1` — Focus Music
```json
[
  { "videoId": "string", "title": "string", "tags": ["string"], "fav": false }
]
```

---

### 1.4 Core Application Logic

#### Challenge Configuration
```javascript
const START_DATE = new Date(2026, 3, 7); // April 7, 2026
const TOTAL_DAYS = 30;
// WEEKDAY_DATES: array of 30 Mon-Fri date strings, skipping weekends
```

#### Pillar System
```
Pillar I (Mind):   sanctuary && ledger && noConsume
Pillar II (Body):  timer && horizon && walk

Both pillars = clean day = streak increment
```

#### Focus Score Formula
```
Base score = 50
+20 if Pillar I complete
+20 if Pillar II complete
+5 per deep work session (max +20)
-3 per distraction (max -15)
+5 if mood >= 4
= capped 0–100
```

#### Rating from Score
```
>= 90 → Excellent
>= 75 → Strong
>= 55 → Solid
>= 35 → Okay
< 35  → Rough
```

#### Streak Logic
```
Start from yesterday if today has no EOD log yet
Skip exempt days (holiday/sick/travel/ooo) without breaking streak
Break on any non-exempt day missing both pillars
```

#### Workday Calendar
```
Challenge: Mon–Fri only (weekends excluded)
"Tomorrow" on Friday = Monday
nextWorkday(dateStr) returns the next Mon–Fri date
```

---

### 1.5 Feature Modules

#### A. Morning Setup (4-step modal)
1. Gratitude text input
2. Energy level picker (1–5 emoji)
3. Top 3 priorities (text inputs)
4. Yesterday's carry-over (incomplete time block tasks, with checkboxes)

On complete: saves `morning-setup-v1`, creates "Carry-over" time block if tasks selected, shows unified hero banner.

#### B. Deep Work Timer
- Countdown: 15 / 25 / 50 / custom minutes
- Extension: +5 / +10 / +15 mid-session
- Deadline-based (wall clock) to prevent drift
- On complete: triggers session log modal

#### C. Session Log Modal
- Task selection: From Asana list (searchable) or custom text
- Duration (matches timer or custom)
- Focus type selector
- Energy level (1–4)
- Notes field
- On save: writes to `30day-sessions-v1`, marks Asana tasks as pending completion

#### D. Time Blocking Page
- 6 AM–10 PM timeline, 1.5px per minute (90px per hour)
- Blocks: color-coded, sized by duration
- 3 render modes by block height:
  - Tiny (<32px): single-line pill
  - Compact (32–72px): header + first task
  - Full (>72px): header + scrollable task list
- Drag tasks from Asana panel onto blocks or empty slots
- Priority tasks float to top priority strip
- "Now" line updates every 60 seconds

#### E. Distraction Logger
- Quick-log: what, type, duration (0–60 min), trigger
- Sidebar mini-log shows today's distractions
- Keyword cloud analysis: extracts high-value terms, scores by frequency × time lost
- Pattern analysis by time-of-day and category

#### F. End-of-Day Modal
- Pillar checklist (6 checkboxes)
  - Sanctuary and Clean Focus default to checked
- Walk count + final step count
- Mood selector (1–5)
- Win of the day
- Notes / reflection
- Tomorrow's intention (label changes Friday → "Monday's Top Intention")
- On save: computes focus score, writes to `30day-traction-v2`, triggers Notion sync

#### G. 30-Day Heatmap
- True calendar grid (Mon–Fri columns, no weekends)
- Starts on correct day-of-week (Day 1 = April 7 = Tuesday)
- Cell colors: gray (future), red (missed), 3-level emerald (logged, by score)
- Exempt days: purple with emoji
- Hover popover: score bar, rating, pillars, sessions, steps, win
- Click to open day detail modal

#### H. Notion Sync
- Proxy URL: `https://notion-proxy-url/sync`
- Creates or updates a page in a specified Notion database
- Auto-retries on 404 (deleted page) by clearing stored page ID and re-creating
- Stores `notion-page-map-v1`: `{ "YYYY-MM-DD": "notion_page_id" }`

#### I. Box Breathing
- 4×4×4×4 pattern (16 seconds per cycle, 4 cycles = 64 seconds)
- 3-second countdown before start
- Animated orb: expands on inhale (96px), shrinks on exhale (40px)
- Circular progress arc (not square ring)
- Fullscreen mode available

#### J. Focus Music
- YouTube links stored locally
- Tag-based filtering
- Favorites system
- Opens in new tab (file:// blocks embeds)

---

### 1.6 AI-Assisted Features

These are the only places the AI model is invoked:

| Feature | Trigger | Input | Expected Output |
|---------|---------|-------|-----------------|
| Distraction keyword extraction | On distraction analysis render | Array of `{what, trigger, mins}` | Top 25 keywords scored by frequency × time |
| Carry-over suggestion | Morning setup step 4 | Yesterday's incomplete tasks | Ranked list with suggested durations |
| Daily insight quote | Page load | Current date (seed) | One of 12 pre-loaded quotes (deterministic, no API needed) |
| Notion page formatting | EOD save | Full daily log object | Formatted Notion page properties JSON |
| Smart summary (future) | Weekly review | 5 days of logs | 2–3 sentence narrative summary |

**Note:** The current implementation uses deterministic logic (not API calls) for quote rotation and keyword extraction. The AI layer is optional enhancement, not core functionality.

---

### 1.7 Evaluation Criteria

**Good output:**
- Focus score accurately reflects actual pillar completion + session count + distractions
- Streak correctly skips exempt days and handles today-not-yet-logged edge case
- Time blocks render in correct calendar positions (Day 1 = Tuesday, not Monday)
- Notion sync creates one page per day, updates on re-sync, recovers from deleted pages
- Morning setup carry-over only shows tasks from the previous workday (skips weekends)
- "Tomorrow" label correctly shows "Monday" on Fridays

**Bad output:**
- Any JS error that crashes `renderAll()` and makes data appear to vanish (data is always safe in localStorage)
- Streak showing 0 when previous days are clean (caused by today-has-no-log edge case)
- Duplicate Notion pages (caused by creating instead of updating)
- Time blocks appearing in wrong day-of-week columns

---

## PART 2: GEMINI / GOOGLE AI STUDIO SPECIFICATION

---

### 2.1 System Instructions (copy into Google AI Studio System Instructions field)

```
You are the intelligence layer for Traction Hub, a personal productivity and wellness dashboard. You are not a conversational assistant — you are called programmatically to perform specific analytical and formatting tasks.

You never engage in conversation. You always return structured JSON unless explicitly asked for plain text.

Your role is to:
1. Extract meaningful keywords from distraction logs
2. Suggest task priorities and time estimates
3. Format daily log data for Notion API consumption
4. Generate brief, motivating summaries of weekly performance

Rules:
- Return only valid JSON when a schema is specified
- Never add commentary, explanations, or preamble outside the JSON structure
- If input data is insufficient, return the schema with empty/null fields rather than refusing
- Keep all text outputs concise — this data appears in a UI with limited space
- Do not fabricate data — only summarize or reformat what was provided
- Preserve exact user-written text in summaries; do not paraphrase their words
```

---

### 2.2 Prompt Templates

---

#### Template 1: Distraction Keyword Extraction

**When called:** After distraction panel renders, when 3+ distractions are logged.

**System instruction addition:** (append to base system instructions)
```
You extract meaningful keywords from distraction log entries. You ignore filler words, pronouns, conjunctions, prepositions, and common verbs. You only extract nouns, proper nouns, and specific named things that reveal what actually distracted the user.
```

**User message template:**
```
Extract the top keywords from these distraction log entries. Return only the 15 most meaningful keywords, scored by importance.

Distraction entries:
{{DISTRACTION_ENTRIES_JSON}}

Return this exact JSON structure:
{
  "keywords": [
    {
      "word": "string",
      "score": number,
      "frequency": number,
      "totalMins": number
    }
  ]
}

Score = (frequency * 2) + (totalMins * 0.1). Sort by score descending.
Exclude: pronouns, articles, prepositions, common verbs (is, was, want, need, try, get, go, came, went, came), time words (today, yesterday, morning, now), quantity words (few, lot, much, many, some, any).
```

**Example input:**
```json
[
  {"what": "Checked LinkedIn messages about Magpie partnership", "trigger": "notification sound", "mins": 8},
  {"what": "Read article about Anthropic funding round", "trigger": "Slack link", "mins": 15},
  {"what": "LinkedIn post about competitor CrowdCom", "trigger": "boredom", "mins": 5}
]
```

**Expected output:**
```json
{
  "keywords": [
    {"word": "LinkedIn", "score": 4.6, "frequency": 2, "totalMins": 13},
    {"word": "Magpie", "score": 2.8, "frequency": 1, "totalMins": 8},
    {"word": "Anthropic", "score": 2.5, "frequency": 1, "totalMins": 15},
    {"word": "CrowdCom", "score": 2.5, "frequency": 1, "totalMins": 5},
    {"word": "Slack", "score": 2.0, "frequency": 1, "totalMins": 0}
  ]
}
```

---

#### Template 2: Carry-over Task Ranking

**When called:** Morning setup step 4, when yesterday had incomplete time block tasks.

**User message template:**
```
I have incomplete tasks from yesterday. Rank them by how important they likely are to address today, and suggest a realistic duration for each.

Incomplete tasks:
{{INCOMPLETE_TASKS_JSON}}

Today's stated priorities (if morning setup already completed):
{{PRIORITIES_ARRAY}}

Return this exact JSON structure:
{
  "ranked": [
    {
      "id": "string",
      "name": "string",
      "suggestedDurMins": number,
      "reason": "string (max 8 words)"
    }
  ]
}
```

**Example input:**
```json
{
  "incomplete_tasks": [
    {"id": "tb_001", "name": "Finalize S7 Corporate Deck", "blockName": "Deep Work", "originalDurMins": 60},
    {"id": "tb_002", "name": "Reply to Momentum Works email", "blockName": "Admin", "originalDurMins": 20},
    {"id": "tb_003", "name": "Comment on LinkedIn Daily", "blockName": "Social Media", "originalDurMins": 15}
  ],
  "priorities": ["Close the Magpie deal", "Finish corporate deck", "Review financials"]
}
```

**Expected output:**
```json
{
  "ranked": [
    {"id": "tb_001", "name": "Finalize S7 Corporate Deck", "suggestedDurMins": 60, "reason": "Matches top priority directly"},
    {"id": "tb_002", "name": "Reply to Momentum Works email", "suggestedDurMins": 20, "reason": "Time-sensitive communication"},
    {"id": "tb_003", "name": "Comment on LinkedIn Daily", "suggestedDurMins": 15, "reason": "Routine — lower urgency"}
  ]
}
```

---

#### Template 3: Notion Page Properties Formatter

**When called:** On EOD save, to format the log object into Notion API property format.

**User message template:**
```
Format this daily log as Notion page properties JSON. Map each field to its Notion property name and type exactly as specified.

Daily log:
{{DAILY_LOG_JSON}}

Sessions:
{{SESSIONS_JSON}}

Property mapping:
- "Day" (title): "Day {dayNumber} — {date}"
- "date:Date:start" (date): "{YYYY-MM-DD}"
- "Day Number" (number): dayNumber
- "Focus Score" (number): focusScore
- "Overall Rating" (select): "⭐ 1 - Rough" | "⭐⭐ 2 - Okay" | "⭐⭐⭐ 3 - Solid" | "⭐⭐⭐⭐ 4 - Strong" | "⭐⭐⭐⭐⭐ 5 - Excellent"
- "Pillar I Complete" (checkbox): pillar1
- "Pillar II Complete" (checkbox): pillar2
- "Deep Work Sessions" (number): session count
- "Total Deep Work Mins" (number): total session minutes
- "Distractions Logged" (number): distractCount
- "Distraction Mins Lost" (number): distractMinsLost
- "Steps Today" (number): steps
- "Horizon Walks Completed" (number): walks
- "Sanctuary Account Used" (checkbox): sanctuary
- "50-Min Timer Used" (checkbox): timer
- "Ledger of Intent Written" (checkbox): ledger
- "No Consumption During Deep Work" (checkbox): noConsume
- "Win of the Day" (rich_text): win
- "Reflection / Notes" (rich_text): notes
- "Tomorrow's Intention" (rich_text): tomorrow
- "Avg Energy Level" (select): "😓 Low" | "😐 Medium" | "⚡ High" | "🔥 Peak"
- "Session Log" (rich_text): formatted session summary
- "Ledger Log" (rich_text): formatted ledger entries

Return only the properties object as valid JSON. Use "__YES__" for checked checkboxes, "__NO__" for unchecked. Use null for missing optional fields.
```

**Expected output format:**
```json
{
  "Day": "Day 7 — 2026-04-15",
  "date:Date:start": "2026-04-15",
  "date:Date:is_datetime": 0,
  "Day Number": 7,
  "Focus Score": 83,
  "Overall Rating": "⭐⭐⭐⭐ 4 - Strong",
  "Pillar I Complete": "__YES__",
  "Pillar II Complete": "__YES__",
  "Deep Work Sessions": 3,
  "Total Deep Work Mins": 170,
  "Distractions Logged": 1,
  "Distraction Mins Lost": 8,
  "Steps Today": 7903,
  "Horizon Walks Completed": 3,
  "Sanctuary Account Used": "__YES__",
  "50-Min Timer Used": "__YES__",
  "Ledger of Intent Written": "__YES__",
  "No Consumption During Deep Work": "__YES__",
  "Win of the Day": "Closed the Magpie intro meeting",
  "Reflection / Notes": "Strong focus morning, fell off after 2pm",
  "Tomorrow's Intention": "Finish the S7 deck first thing",
  "Avg Energy Level": "⚡ High",
  "Session Log": "Session 1: 50min | Deep Work | Energy: 3\nSession 2: 60min | Writing | Energy: 4",
  "Ledger Log": "[10:03 AM] Researching Magpie competitors"
}
```

---

#### Template 4: Weekly Performance Summary

**When called:** On demand from weekly summary section.

**User message template:**
```
Write a 2–3 sentence performance summary for this work week. Be direct and specific. Reference actual numbers. Use "you" not "the user". End with one actionable observation.

Week data:
{{WEEK_DATA_JSON}}

Return this exact JSON structure:
{
  "summary": "string (2-3 sentences, max 120 words)",
  "topWin": "string (best win from the week, verbatim from data)",
  "focusPattern": "morning|afternoon|evening|inconsistent"
}
```

---

### 2.3 Tool / Function Schemas (for Gemini Function Calling)

If using Gemini's function calling feature, define these tools:

#### Tool: `extract_distraction_keywords`
```json
{
  "name": "extract_distraction_keywords",
  "description": "Extract and score meaningful keywords from distraction log entries to reveal attention patterns",
  "parameters": {
    "type": "object",
    "properties": {
      "entries": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "what": { "type": "string" },
            "trigger": { "type": "string" },
            "mins": { "type": "number" }
          }
        }
      }
    },
    "required": ["entries"]
  }
}
```

#### Tool: `rank_carryover_tasks`
```json
{
  "name": "rank_carryover_tasks",
  "description": "Rank incomplete tasks from yesterday by today's priority context",
  "parameters": {
    "type": "object",
    "properties": {
      "tasks": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "id": { "type": "string" },
            "name": { "type": "string" },
            "blockName": { "type": "string" },
            "originalDurMins": { "type": "number" }
          }
        }
      },
      "todayPriorities": {
        "type": "array",
        "items": { "type": "string" }
      }
    },
    "required": ["tasks"]
  }
}
```

#### Tool: `generate_weekly_summary`
```json
{
  "name": "generate_weekly_summary",
  "description": "Generate a brief narrative summary of weekly productivity performance",
  "parameters": {
    "type": "object",
    "properties": {
      "weekData": {
        "type": "object",
        "properties": {
          "days": { "type": "number" },
          "cleanDays": { "type": "number" },
          "avgFocusScore": { "type": "number" },
          "totalDeepMins": { "type": "number" },
          "totalDistractions": { "type": "number" },
          "totalSteps": { "type": "number" },
          "wins": { "type": "array", "items": { "type": "string" } },
          "sessions": { "type": "array", "items": { "type": "object" } }
        }
      }
    },
    "required": ["weekData"]
  }
}
```

---

### 2.4 React Component Architecture

```
src/
├── App.jsx                    # Router: Dashboard | TimeBlocks pages
├── main.jsx
├── index.css                  # Tailwind + custom CSS (from existing styles)
│
├── store/
│   ├── useAppStore.js         # Zustand store — all localStorage state
│   ├── schemas.js             # TypeScript/JSDoc schemas for all data types
│   └── constants.js           # START_DATE, TOTAL_DAYS, WEEKDAY_DATES, etc.
│
├── hooks/
│   ├── useDailyLog.js         # CRUD for 30day-traction-v2
│   ├── useSessions.js         # CRUD for 30day-sessions-v1
│   ├── useDistract.js         # CRUD for 30day-distract-v1
│   ├── useLedger.js           # CRUD for 30day-ledger-v1
│   ├── useTimeBlocks.js       # CRUD for 30day-blocks-v1
│   ├── useMorningSetup.js     # morning-setup-v1
│   ├── useTimer.js            # Deep work countdown timer
│   ├── useBreath.js           # Box breathing state machine
│   └── useNotionSync.js       # Notion API sync logic
│
├── utils/
│   ├── dateUtils.js           # todayStr, nextWorkday, WEEKDAY_DATES builder
│   ├── scoring.js             # computeFocusScore, scoreToRating, streakCalc
│   ├── gemini.js              # Gemini API client + all prompt templates
│   └── asana.js               # Asana API client
│
├── components/
│   ├── layout/
│   │   ├── Sidebar.jsx
│   │   ├── Header.jsx
│   │   └── MobileNav.jsx
│   │
│   ├── hero/
│   │   └── HeroCard.jsx       # Quote + Intention + Morning context unified card
│   │
│   ├── stats/
│   │   └── StatsRow.jsx       # 4 stat cards
│   │
│   ├── deepwork/
│   │   ├── DeepWorkSection.jsx
│   │   ├── Timer.jsx
│   │   └── SessionsPanel.jsx
│   │
│   ├── movement/
│   │   └── MovementHydration.jsx
│   │
│   ├── heatmap/
│   │   ├── HeatmapCard.jsx
│   │   ├── HeatmapCell.jsx
│   │   └── HeatmapPopover.jsx
│   │
│   ├── breathing/
│   │   ├── BoxBreathCard.jsx
│   │   └── BoxBreathFullscreen.jsx
│   │
│   ├── timeblocks/
│   │   ├── TimeBlocksPage.jsx
│   │   ├── Timeline.jsx
│   │   ├── TimeBlock.jsx
│   │   ├── AsanaPanel.jsx
│   │   ├── PriorityStrip.jsx
│   │   └── CreateBlockModal.jsx
│   │
│   ├── modals/
│   │   ├── EodModal.jsx
│   │   ├── SessionModal.jsx
│   │   ├── DistractionModal.jsx
│   │   ├── LedgerModal.jsx
│   │   ├── MorningSetupModal.jsx
│   │   ├── DayDetailModal.jsx
│   │   └── WaterModal.jsx
│   │
│   ├── music/
│   │   └── MusicPlayer.jsx
│   │
│   ├── history/
│   │   ├── HistoryTable.jsx
│   │   └── WeeklySummary.jsx
│   │
│   └── shared/
│       ├── Toast.jsx
│       ├── Badge.jsx
│       ├── Card.jsx
│       └── Modal.jsx          # Base modal wrapper with backdrop
```

---

### 2.5 Gemini API Integration (React)

#### `src/utils/gemini.js`
```javascript
const GEMINI_API_KEY = import.meta.env.VITE_GEMINI_API_KEY;
const GEMINI_MODEL = 'gemini-1.5-flash'; // or gemini-1.5-pro for higher quality
const BASE_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

const SYSTEM_INSTRUCTION = `You are the intelligence layer for Traction Hub, a personal productivity and wellness dashboard. You are not a conversational assistant — you are called programmatically to perform specific analytical and formatting tasks. You never engage in conversation. You always return structured JSON unless explicitly asked for plain text. Never add commentary, explanations, or preamble outside the JSON structure. If input data is insufficient, return the schema with empty/null fields rather than refusing.`;

async function callGemini(userPrompt, options = {}) {
  const body = {
    system_instruction: { parts: [{ text: SYSTEM_INSTRUCTION }] },
    contents: [{ role: 'user', parts: [{ text: userPrompt }] }],
    generationConfig: {
      temperature: options.temperature ?? 0.2,
      maxOutputTokens: options.maxTokens ?? 1024,
      responseMimeType: 'application/json',
    },
  };

  const res = await fetch(`${BASE_URL}?key=${GEMINI_API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  if (!res.ok) throw new Error(`Gemini API error: ${res.status}`);
  const data = await res.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  return JSON.parse(text);
}

export async function extractDistractionKeywords(entries) {
  const prompt = `Extract the top 15 keywords from these distraction entries.
Entries: ${JSON.stringify(entries)}
Score = (frequency * 2) + (totalMins * 0.1). Sort descending.
Exclude pronouns, articles, prepositions, common verbs, time words, filler words.
Return: { "keywords": [{ "word": string, "score": number, "frequency": number, "totalMins": number }] }`;
  return callGemini(prompt);
}

export async function rankCarryoverTasks(tasks, priorities = []) {
  const prompt = `Rank these incomplete tasks by how important they are to address today.
Tasks: ${JSON.stringify(tasks)}
Today's priorities: ${JSON.stringify(priorities)}
Return: { "ranked": [{ "id": string, "name": string, "suggestedDurMins": number, "reason": string }] }
Reason must be max 8 words.`;
  return callGemini(prompt);
}

export async function generateWeeklySummary(weekData) {
  const prompt = `Write a 2–3 sentence performance summary for this work week. Be direct, specific, use actual numbers, address the user as "you". End with one actionable observation.
Data: ${JSON.stringify(weekData)}
Return: { "summary": string, "topWin": string, "focusPattern": "morning|afternoon|evening|inconsistent" }`;
  return callGemini(prompt, { temperature: 0.5 });
}
```

---

### 2.6 State Management Recommendation

Use **Zustand** for global state, with localStorage persistence via `zustand/middleware/persist`:

```javascript
// src/store/useAppStore.js
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

export const useAppStore = create(
  persist(
    (set, get) => ({
      // Daily logs keyed by date
      logs: {},
      setLog: (date, log) => set(s => ({ logs: { ...s.logs, [date]: log } })),

      // Sessions keyed by date
      sessionLog: {},
      addSession: (date, session) => set(s => ({
        sessionLog: { ...s.sessionLog, [date]: [...(s.sessionLog[date] || []), session] }
      })),

      // Time blocks keyed by date
      timeBlocks: {},
      setDayBlocks: (date, blocks) => set(s => ({ timeBlocks: { ...s.timeBlocks, [date]: blocks } })),

      // ... other slices
    }),
    {
      name: '30day-traction-v2', // matches existing localStorage key
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        logs: state.logs,
        sessionLog: state.sessionLog,
        timeBlocks: state.timeBlocks,
        // etc.
      }),
    }
  )
);
```

---

## PART 3: FEATURES THAT NEED APP-LAYER APPROXIMATION

---

### 3.1 Persistent Memory (Long-term Context)

**What it was:** The dashboard "remembers" everything via localStorage — 30 days of logs, sessions, blocks, all accessible on every interaction.

**In standard chat APIs:** Context window is per-conversation, not persistent.

**Solution in React:** This is already handled — localStorage IS the persistent memory. Gemini is only called for specific analytical tasks with the relevant data passed in the prompt. No long-term memory needed in the API layer.

---

### 3.2 Deterministic Daily Quote

**What it was:** `seed = year * 10000 + month * 100 + day; idx = seed % 12` — same quote all day, rotates daily.

**In React:** Keep this pure JavaScript logic. No API call needed. Maintain the 12-quote array in `constants.js`.

---

### 3.3 Notion Sync (Proxy Pattern)

**What it was:** A Notion API proxy at a fixed URL that handles authentication server-side.

**In React:** You need a lightweight backend for this — Notion API requires server-side auth to avoid exposing the integration token. Options:
1. **Vercel Edge Function** — 10 lines of code, free tier covers this easily
2. **Cloudflare Worker** — same
3. **Keep user's token in localStorage** and call Notion directly (less secure but works)

The existing implementation passes the token from localStorage, so option 3 is already implemented — just replicate the proxy logic.

---

### 3.4 Asana Integration

**What it was:** ASANA_TASKS is a static hardcoded array baked into the HTML at generation time.

**In React:** Fetch from Asana API on load using a Personal Access Token stored in localStorage. Cache results in state to avoid repeated calls. Key endpoint: `GET /tasks?workspace={id}&assignee=me&completed_since=now`.

---

### 3.5 Real-time Timer (Drift Prevention)

**What it was:** `timerDeadlineAt` — stores epoch ms of when timer should end, checks against `Date.now()` each tick instead of counting down.

**In React:** Use the same pattern in `useTimer.js`:
```javascript
const tick = () => {
  const remaining = Math.max(0, Math.round((deadlineAt - Date.now()) / 1000));
  setSecsLeft(remaining);
  if (remaining === 0) onComplete();
};
useEffect(() => {
  const id = setInterval(tick, 500); // 500ms for responsiveness
  return () => clearInterval(id);
}, [running, deadlineAt]);
```

---

### 3.6 Drag and Drop (Time Blocks)

**What it was:** Native HTML5 drag/drop with `dragstart`, `dragover`, `drop` events.

**In React:** Use **@dnd-kit/core** — it's the modern React DnD library that handles both mouse and touch, works well with sorted lists and free-position drop zones. The timeline's pixel-position math stays the same: `minutesToY(mins) = (mins - START_HOUR * 60) * PX_PER_MIN`.

---

*End of Specification Document*
*Version 1.0 — April 2026*
*Built from: 30-Day-Traction-Dashboard.html (8,447 lines)*
