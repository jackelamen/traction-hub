# Tasks Module Spec (TickTick Clone, v1)

**Working name:** EDGEx Tasks (codename: *Pulse*)
**Owner:** Jack
**Spec date:** 2026-05-07
**Status:** Draft for review

---

## 1. Vision in one paragraph

Build a task manager that takes the breadth of TickTick (tasks + calendar + pomodoro + habits in one app) and pairs it with the calmness and craft of Things 3 and the keyboard speed of Linear. Mobile-first responsive. Standalone first, then folds into TheEDGEx as the *Tasks* module.

## 2. Why this exists

TickTick is functionally rich but visually noisy and feels like four apps glued together. The four core jobs (capture, plan, focus, follow through) deserve a single coherent surface where the same task object flows from inbox to calendar to focus session to completion log without you re-entering data or context-switching between modes.

## 3. Target user (you)

A productivity-systems-literate operator who already runs TheEDGEx, lives in keyboard shortcuts, time-blocks the day, runs deep-work sessions, and tracks habits. The product should not have a tutorial. It should reward fluency.

## 4. Scope for v1

In scope (chosen by Jack): tasks + lists/projects, calendar + time blocking, pomodoro/focus timer, habits + recurring routines.

Explicitly out of scope for v1: collaboration/sharing, comments, attachments, AI auto-scheduling, voice input, third-party calendar sync (Google/Outlook), email-to-task, browser extensions, mobile native apps.

## 5. Tech stack

**Decision:** Next.js 14+ (App Router) + Supabase + Tailwind + shadcn/ui.

- **Frontend:** Next.js (App Router, RSC where it helps, Client Components for the interactive surfaces), TypeScript strict, Tailwind, shadcn/ui as the component primitive layer, Lucide icons, Framer Motion for the few animations that matter (drag-drop, complete checkmark, panel transitions).
- **Data:** Supabase Postgres + Row Level Security, Supabase Realtime for cross-tab sync, Supabase Auth (email + magic link).
- **State:** React Server Components for initial loads, TanStack Query for client-side mutations and optimistic updates, Zustand for ephemeral UI state (selected task, sidebar collapse, command palette).
- **Hosting:** Vercel for the standalone phase. PWA-enabled so the mobile experience installs to the home screen.

### Integration approach (decided)

**Pulse will live on its own subdomain (e.g. `tasks.theedgex.com`) and share the existing TheEDGEx Supabase project (`mdkyijbgvxedelcqcouu`) for auth and data.** No code merge with the HTML modules. Visual continuity comes from a shared design system (sidebar navy `#1a1a2e`, light main `#f8f9fc`, Inter + Manrope + Material Symbols Rounded, per-module accent color), not a shared codebase.

**What "shared data" means in practice:**
- Single Supabase Auth session. The user logs in once at `theedgex.com/login.html`, the session token (already stored in localStorage as `sb_session`) is readable by `tasks.theedgex.com` provided both run under the same parent domain. If the subdomains do not share a parent domain at deploy time, fall back to a Supabase magic-link handoff or store the session in a cookie scoped to `.theedgex.com`.
- All Pulse tables (`lists`, `tasks`, `habits`, `habit_logs`, `focus_sessions`, etc.) live in the same Postgres schema as everything else, with `user_id` RLS so each module reads only what belongs to the signed-in user.
- The other modules (`work.html`, `goals.html`, `wellness.html`, etc.) can read from `tasks` directly via the Supabase JS client. For example, `work.html` can show "today's tasks" alongside its time-blocking UI by querying `tasks where user_id = auth.uid() and start_at::date = today`. No API layer between them.
- Conversely, Pulse can surface goals from `goals.html` and habits already tracked in `wellness.html` if those tables are extended later. The point is one Postgres, many UIs.

**Implications baked into the build:**
- Table and column names stay neutral (no `pulse_` prefix). Other modules will query them directly.
- Every write goes through Supabase RLS. No service-role keys in the Next.js client. Edge functions are fine when needed.
- The Next.js app uses `@supabase/ssr` so that auth cookies set on `.theedgex.com` work seamlessly across modules.

## 6. Data model

All tables get `user_id uuid references auth.users` and RLS policies that scope every read/write to the owning user. All tables get `created_at`, `updated_at`, `deleted_at` (soft delete).

### `lists`
Top-level container. TickTick calls these "lists" or "projects." We use `lists`.
- `id uuid pk`
- `name text`
- `color text` (hex, for left-sidebar dot)
- `icon text` (Lucide icon name, optional)
- `view_mode text` (list | board | timeline, default list)
- `sort_order int` (manual ordering in sidebar)
- `archived_at timestamptz`

### `folders`
Optional grouping above lists, for users with many lists.
- `id uuid pk`
- `name text`
- `sort_order int`

`lists.folder_id uuid nullable` references `folders`.

### `tasks`
The core object. Designed so a task is the same row whether it lives in inbox, on the calendar, or inside a focus session.
- `id uuid pk`
- `list_id uuid` references `lists` (nullable means inbox)
- `parent_task_id uuid` references `tasks` (subtasks)
- `title text`
- `notes text` (markdown)
- `priority smallint` (0 none, 1 low, 2 medium, 3 high)
- `status text` (todo | in_progress | done | cancelled)
- `start_at timestamptz` (when scheduled to start, used by calendar)
- `due_at timestamptz` (deadline, separate from start)
- `duration_minutes int` (estimated, used for time-blocking)
- `all_day boolean`
- `completed_at timestamptz`
- `recurrence_rule text` (RRULE string per RFC 5545; lives on the template row)
- `recurrence_parent_id uuid` (links materialized exception rows back to the template; virtual instances do not exist as rows until completed, edited, or skipped)
- `sort_order numeric` (fractional indexing for drag-reorder)
- `tags text[]`

Indexes: `(user_id, list_id, sort_order)`, `(user_id, due_at)`, `(user_id, start_at)`, `(user_id, completed_at)`, gin on `tags`.

### `tags`
Optional explicit tag table for autocomplete and color/rename.
- `id uuid pk`
- `name text unique per user`
- `color text`

### `habits`
- `id uuid pk`
- `name text`
- `cadence text` (daily | weekdays | weekly | custom)
- `cadence_config jsonb` (e.g. `{"days":[1,3,5]}` for custom)
- `target_per_period int` (default 1)
- `color text`
- `icon text`
- `archived_at timestamptz`
- `sort_order int`

### `habit_logs`
- `id uuid pk`
- `habit_id uuid` references `habits`
- `logged_on date` (the day it counts toward, in user's TZ)
- `count int` (default 1, supports "drink water 3x")
- `note text`

Unique on `(habit_id, logged_on)` when `target_per_period = 1`. Otherwise allow multiple rows per day.

### `focus_sessions`
- `id uuid pk`
- `task_id uuid` references `tasks` (nullable, free-form sessions allowed)
- `started_at timestamptz`
- `ended_at timestamptz`
- `planned_minutes int`
- `actual_minutes int`
- `mode text` (pomodoro | flow | custom)
- `interruptions int`
- `note text`

### `views` (saved smart lists)
- `id uuid pk`
- `name text`
- `filter jsonb` (the query: `{tag:"deep-work", priority:[2,3], due_before:"+7d"}`)
- `sort_order int`

### `user_settings`
Single row per user. Stores preferences (default view, week start day, work hours, pomodoro defaults, theme accent, density).

### Mapping into TheEDGEx later

Naming convention is deliberately neutral so a future EDGEx schema can adopt these tables wholesale. The `tasks` table is already shaped to support the work.html time-blocking patterns (start_at + duration_minutes mirror what work.html does in localStorage today). Plan: at integration time, migrate work.html's local time blocks into `focus_sessions`, and the morning-setup task list into `tasks`. No rename needed.

## 7. Screen inventory

### Top-level navigation (left sidebar, collapsible)

Pinned views: **Inbox**, **Today**, **Upcoming**, **Anytime**, **Someday**, **Logbook**.
Then: **Calendar**, **Habits**, **Focus**.
Then: user folders + lists (drag-reorderable), then **Tags**, then **Saved views**.

Footer of sidebar: quick-add, search, settings.

### 7.1 Inbox

Frictionless capture surface. Single input at top with natural-language parsing ("Email Sarah tomorrow at 9am !high #work"). Below: flat list of unsorted tasks. No grouping. The point is to get it out of your head and triage later.

### 7.2 Today

The home screen. Sections, top to bottom:
1. **Leftover from yesterday** (only renders when stale incomplete items exist, with bulk-action chips: reschedule all to today / push to tomorrow / send to inbox / mark done)
2. **Habits due today** (thin row of habit cards, tap to log)
3. **Morning intention** (one-line input, persisted per day, optional)
4. **Scheduled today** (time-blocked tasks shown as a vertical timeline on the right, list on the left)
5. **Anytime today** (no specific time, just due today)

End of day: a "Done today" disclosure at the bottom shows completed tasks and completed habit logs as two sibling read-only lists, with totals.

### 7.3 Upcoming

Week-at-a-glance plus next-30-days list. Drag tasks between days. Today is anchored at the top. Empty days shown faintly so the eye can find slack.

### 7.4 List/project view

The body of the app for project work. Three view modes per list:
- **List** (default): grouped by section, drag to reorder, inline edit.
- **Board** (kanban): columns are status by default, configurable to priority or custom field.
- **Timeline** (gantt-lite): tasks with start_at + duration plotted on a horizontal timeline. Drag to move/resize.

### 7.5 Calendar

Day, 3-day, week, month views. Time-blocked tasks render as events. Drag from the right-side "unscheduled" rail onto the canvas to schedule. Click an empty slot to create a task in place. Habits show as faint background bands on relevant days.

### 7.6 Habits

Top: today's habits as large checkbox cards. Tap to log.
Middle: heatmap (GitHub-style) per habit, last 90 days.
Bottom: stats (current streak, longest streak, completion rate this month).
Settings per habit accessible via right-click or long-press.

### 7.7 Focus

Big timer (pomodoro by default: 25/5, configurable). When a task is selected, its title shows above the timer. Distraction logger sits below the timer (one tap to log "context switch" or "interruption" without breaking the session). Session history appears as a small bar chart of the last 7 days.

When the timer hits zero in default (soft) mode, a gentle chime plays and a banner appears: "Break time? You can keep going." The session keeps running and the timer flips to count up in a muted color so you can see how far past the plan you went. `actual_minutes` records real elapsed time on stop. **Strict mode** (settings toggle) hard-stops the session at planned duration with no override.

### 7.8 Search + command palette (Cmd+K)

Global Cmd+K opens a palette. Three modes auto-detected from input:
- starts with `/` → command (e.g. `/today`, `/new task`, `/focus 25m`)
- starts with `#` → tag jump
- starts with `@` → list/folder jump
- otherwise → fuzzy task search across all tasks.

### 7.9 Settings

Account, theme (light/dark/auto, accent color), density (comfortable/compact), week starts on, work hours (used by calendar shading), pomodoro defaults, keyboard shortcuts reference, data export (JSON), danger zone.

## 8. UX principles

1. **Capture is sacred.** From any screen, pressing `n` or tapping the floating + opens a quick-add overlay that defaults to inbox. Natural-language date parsing is non-negotiable.
2. **One object, many views.** A task on the calendar is the same row as a task in a list. Edit it anywhere, it updates everywhere via Supabase Realtime.
3. **Keyboard-first, touch-fluent.** Every action has a shortcut. Every shortcut has a touch equivalent (swipe right to complete, swipe left to schedule, long-press for context menu).
4. **Whitespace is a feature.** Default density is generous. Compact mode exists for power users but is not the default.
5. **Earned color.** Lists have colors. Priorities have colors. Almost nothing else does. Color carries information; it does not decorate.
6. **Quiet completion.** Checking a task off plays a soft strike-through animation and a barely-audible tick. No confetti, no celebration. The reward is the empty list at the end of the day.
7. **No empty empty-states.** Every empty state shows the keyboard shortcut to create the first item, plus one example.

## 9. Mobile-first responsive

Breakpoints: 0–640 (mobile), 640–1024 (tablet, single-column with collapsible sidebar), 1024+ (desktop, three-column).

Mobile patterns:
- Bottom tab bar: Today, Upcoming, Lists, Habits, Focus.
- Quick-add is a FAB.
- Swipe gestures: right swipe = complete, left swipe reveals schedule/priority/delete.
- Long-press on a task opens the bottom-sheet editor.
- Calendar on mobile defaults to day view, swipe horizontally between days.
- Pomodoro screen takes full viewport, hides the chrome.

Install as PWA. Service worker caches app shell so the timer works offline; mutations queue and sync when online.

## 10. Keyboard shortcuts (desktop)

- `n` quick add
- `Cmd+K` command palette
- `Cmd+1..9` jump to pinned view N
- `t` set due to today, `m` tomorrow, `w` next week, `s` someday
- `1/2/3` set priority low/med/high, `0` clear priority
- `Space` open task detail panel
- `e` edit title inline
- `Cmd+Enter` complete task
- `Cmd+D` duplicate
- `Cmd+Shift+P` start focus session on selected task
- `g i` go to inbox, `g t` today, `g u` upcoming, `g h` habits, `g c` calendar (vim-style g-prefixed jumps)
- `?` show shortcut overlay

## 11. Performance targets

- First paint on Today < 1.0s on a cold load over 4G.
- Quick-add submission to UI ack < 50ms (optimistic).
- Drag-reorder feel: 60fps, no layout shift.
- Cold open of installed PWA on mobile < 600ms.

## 12. Accessibility

WCAG 2.1 AA target. Keyboard reachable everywhere. Focus rings visible (not the default blur). Color is never the only signal (priorities also use weight + small chip text). Reduced-motion respected. Screen reader: tasks announce title + priority + due, not all the metadata noise.

## 13. Milestones

**M0 — Scaffold (week 1).** Next.js + TypeScript + Tailwind + shadcn set up. Supabase project wired (reuse `mdkyijbgvxedelcqcouu`). Auth flow (email + magic link). Empty Today screen behind login. Deployed to Vercel.

**M1 — Core tasks (week 2).** `lists` and `tasks` tables with RLS. Inbox + a single list view. Add/edit/complete/delete. Quick-add with natural-language date parsing. Keyboard shortcuts for the basics. Today screen shows tasks due today.

**M2 — Multi-list + organization (week 3).** Folders, multiple lists, drag-reorder, tags, priorities, subtasks, list view modes (list/board). Sidebar polish. Search + Cmd+K palette.

**M3 — Calendar + scheduling (week 4).** Calendar screen with day/week/month. Drag-to-schedule from unscheduled rail. start_at/duration on tasks. Upcoming view. Recurrence (RRULE) for tasks.

**M4 — Focus timer (week 5).** Focus screen, pomodoro defaults, distraction logger, session history. Link sessions to tasks. Stats on Today screen.

**M5 — Habits (week 6).** Habits screen, heatmap, streaks. Habits surface on Today. Cadence rules.

**M6 — Mobile polish + PWA (week 7).** Service worker, install prompt, swipe gestures, bottom tab bar, offline queue.

**M7 — v1 launch (week 8).** Settings completed, data export, accessibility audit, performance pass, dogfood for 2 weeks.

**M8+ — TheEDGEx integration.** Subdomain handoff: deploy to `tasks.theedgex.com`, wire shared-cookie auth across `.theedgex.com`, add a Pulse card to `index.html` matching the existing module-card pattern, and surface a "today's tasks" widget inside `work.html` that reads from the `tasks` table via the Supabase client. Happens after v1 has been used daily for at least 3 weeks.

## 14. Resolved decisions

All five questions resolved 2026-05-08. The build assumes these defaults from M0 forward.

1. **Recurrence: compute virtually.** A recurring task is a single template row with an `recurrence_rule` (RRULE). Instances are computed on the fly for the visible date range (Today, Upcoming, Calendar). Only when an instance is completed, edited, or skipped does a concrete row materialize, linked back via `recurrence_parent_id`. This keeps the `tasks` table small and avoids the "1000 future instances" bloat that TickTick suffers from. Trade-off accepted: editing all future instances is the cheap path; per-instance edits create exception rows.
2. **Yesterday's leftovers.** Incomplete items do not silently roll into Today at midnight. They surface in a "Leftover from yesterday" disclosure pinned to the top of the Today screen, with bulk actions (reschedule all to today, push all to tomorrow, send to inbox, mark done). The friction is the feature: it forces a daily triage and prevents the slow accumulation of stale "today" tasks that quietly pile up in TickTick.
3. **Pomodoro: soft suggestion.** When the configured timer (default 25m) hits zero, Pulse plays a gentle chime and shows an unobtrusive banner: "Break time? You can keep going." The session continues running until you stop it, and the actual_minutes field captures real elapsed time, not the planned 25. Hard-stop is available behind a "strict mode" toggle in settings for users who want to enforce the discipline.
4. **Habits and tasks stay separate.** Habit logs live in `habit_logs` and are not duplicated into `tasks`. The Today screen shows habits in their own thin row at the top, separate from the task list below. The "what I did today" view (an end-of-day disclosure on Today) joins both sources read-only for the user-facing feed, but the underlying records remain in their own tables. Cleaner data, fewer write paths, no risk of the two getting out of sync.
5. **Integration: subdomain on `tasks.theedgex.com`, shared Supabase, neutral table names so other HTML modules can read tasks directly.**

### Implications baked into the build

- The `tasks` table keeps `recurrence_rule` and `recurrence_parent_id` exactly as specified in section 6. The query layer (a small `expandRecurrences(range)` helper) is the new piece — it must be performant for the Today/Upcoming/Calendar reads. Plan to use a Postgres function or a TanStack Query selector; benchmark at M3.
- The Today screen layout in section 7.2 gets a new top-most section: **Leftover from yesterday**, above the morning intention. Renders only when there are stale items; collapses to nothing when the day is clean.
- The Focus screen in section 7.7 needs a "still going" state past planned duration, with a visual cue that the session is in overtime. Settings need a "strict mode" toggle.
- The Today screen end-of-day disclosure (mentioned in 7.2 as "Done today") expands to also include "Habits done today" as a sibling section, both read-only.

---

*Once this spec is approved, M0 kicks off. The first deliverable will be a working Next.js + Supabase scaffold with the Today screen behind email auth, deployed to Vercel.*
