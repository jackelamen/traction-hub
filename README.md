# Traction Hub

**Personal productivity and wellness OS** — a single-file HTML dashboard for intentional, focused workdays.

## Live App

🔗 **[Open Traction Hub](https://jackelamen.github.io/traction-hub/30-Day-Traction-Dashboard.html)**

## What It Does

- **Morning Setup** — guided daily ritual: gratitude, energy, top 3 priorities, carry-over tasks
- **Deep Work Timer** — countdown timer with session logging and Asana integration
- **Time Blocking** — visual 6 AM–10 PM daily timeline with drag-and-drop blocks
- **Distraction Logger** — capture interruptions and analyze patterns
- **Ledger of Intent** — capture intention before opening any content tab
- **End-of-Day Reflection** — pillar checklist, mood, wins, tomorrow's intention
- **30-Day Heatmap** — workday-only calendar grid tracking focus scores
- **Notion Sync** — push daily logs to your Notion database
- **Box Breathing** — 4×4×4×4 guided breathing with animated orb
- **Focus Music** — YouTube-linked music player with tag filtering

## How to Use

1. Open the HTML file directly in your browser — no server needed
2. All data is stored in `localStorage` — nothing leaves your device except Notion syncs
3. The app runs Mon–Fri only (weekends skipped intentionally)

## Tech Stack

- Single-file HTML (Tailwind CSS via CDN, vanilla JS)
- No build step, no dependencies, no backend
- Asana REST API (personal access token)
- Notion API (via proxy or direct token)

## Files

| File | Description |
|------|-------------|
| `30-Day-Traction-Dashboard.html` | The full application |
| `3DTD (backup).html` | Earlier backup version |
| `Traction-Hub-Rebuild-Spec.md` | Full spec for React + Gemini rebuild |

---

Built with ☀️ for intentional workdays.
