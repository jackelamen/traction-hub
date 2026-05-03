# Goals Dashboard — Feature & Function Brief

A design-independent specification describing what the application does, how it is structured, and what interactions it supports. This document makes no assumptions about visual design and should be usable by any designer or design system.

---

## Overview

A personal goal management system built for one user. It runs entirely in the browser as a single HTML file with no server or backend. All data is stored locally in the browser (localStorage) and never leaves the device. The application is organized around a goal-setting methodology that links long-term visions to quarterly execution cycles.

---

## Data Model

The application manages three types of structured data:

**Life Areas** — Fixed, non-editable categories that every goal belongs to. There are four:
- Health & Fitness
- Career & Business
- Family
- Personal Development

**Goals** — Each goal belongs to one life area and contains:
- A title
- A motivation statement ("why this matters")
- A status (active, paused, or completed)
- One or more measurable metric targets, each with a name, a numeric target value, and a unit of measurement
- A log of progress entries per metric (date, value recorded, optional note)

**Focus Cycles (Sprints)** — 12-week commitment periods, each containing:
- A linked goal
- A specific objective for that cycle
- A set of weekly tactics — actions the user commits to completing
- A phase structure (weeks 1–4: Foundation, weeks 5–8: Build, weeks 9–12: Peak)
- A weekly reflection record (what went well, obstacles, adjustments, next step)
- A retrospective record completed at cycle end (overall outcome, biggest win, lesson learned, carry-forward action, emoji satisfaction rating)

**Vision Board** — A freeform image collection linked to the user's longer-term vision, stored separately from goal data.

---

## Views

The application has seven distinct views accessible from the main navigation.

### 1. Today

The home view. Shows what requires attention today.

- Displays a personalized greeting and today's date
- Shows key summary statistics: active goals count, current sprint count, overall execution score
- Organizes daily tactics by life area, showing only the tactics due today based on their frequency settings
- For each tactic: shows its name, which goal/sprint it belongs to, and a checkbox to mark it done
- Shows a visual progress bar per life area reflecting how many of today's tactics are checked
- If no tactics are due, displays an appropriate empty state

### 2. Goals

A browsable list of all goals.

- Filterable by life area and by status (active, paused, completed)
- Each goal is shown as a card displaying: title, life area, status, motivation statement, and metric targets with current logged progress
- Tapping a goal navigates to its detail view
- A button to create a new goal

### 3. Goal Detail

A focused view for one goal.

- Displays the goal's full information: title, area, status, why statement
- Shows each metric target with its logged progress as a small chart (sparkline) and a count of log entries
- Tapping a metric opens the metric log panel
- Lists all focus cycles linked to this goal
- Options to edit or delete the goal

### 4. Cycles

The weekly execution hub. This is where the user tracks day-to-day tactic completion.

- Lists all active focus cycles
- Each cycle shows: its objective, linked goal, current phase label, current week number, and an execution score
- The execution score is a ratio of completed checkpoints to possible checkpoints for the current week
- Below each cycle header: a week-by-week tactic grid where rows are tactics and columns are the days or occurrences they are expected
- Each tactic row shows: tactic name, frequency label, a streak badge (consecutive weeks with full completion), and check boxes for the current week
- Tactic frequency types: daily (every day), custom days (specific days of the week), x-per-week (a target count per week), weekly (once per week), one-time (single occurrence)
- A weekly reflection form per cycle: prompted fields for what went well, obstacles faced, adjustments to make, and next week's focus
- A button to create a new cycle
- Completed cycles are accessible via the Retros view

### 5. Roadmap

A visual timeline showing all goals and cycles across time.

- Displays goals and their associated cycles as horizontal bars on a calendar grid
- Allows the user to see how their commitments are distributed over time and whether cycles overlap
- Read-only; no editing from this view

### 6. Visions

An image-based mood board.

- Displays images the user has added representing their vision and aspirations
- Images can be added from local files or pasted URLs
- Images can be removed
- No text content; purely visual

### 7. Retros

A record of completed focus cycles and their retrospectives.

- Lists all cycles that have ended
- For cycles with a saved retrospective: shows the outcome rating, biggest win, lesson, and carry-forward action
- For cycles without a retrospective: shows a prompt to complete one
- Opening a retrospective shows the full reflection form for that cycle

---

## Panels and Modals

In addition to the main views, several overlay panels handle create/edit flows.

**New Goal Panel** — Collects: title, life area, motivation statement, and one or more metric targets (each with name, target value, and unit). Additional metrics can be added dynamically.

**New Cycle Panel** — Collects: linked goal (selected from existing goals), cycle objective, start date, and an initial set of weekly tactics. Each tactic has a name and a frequency type. Additional tactics can be added dynamically.

**Edit Goal Panel** — Same fields as New Goal. Existing metrics and their log history are preserved.

**Sprint Retrospective Panel** — Opens for a specific completed cycle. Collects:
- Overall outcome (one of: crushed it, good progress, mixed, struggled, pivoting)
- Biggest win (free text)
- Main lesson learned (free text)
- One thing to carry forward (free text)
- Satisfaction rating (five-step emoji scale)

**Metric Progress Log Panel** — Opens for a specific metric within a specific goal. Displays:
- A history of all previously logged entries (date, value, note)
- A form to add a new entry: value, date, optional note

---

## Computed Values

The application derives several calculated values from raw data:

**Execution Score (per cycle, per week)** — The number of tactic checkpoints the user completed divided by the total number of checkpoints possible for that week, expressed as a percentage.

**Average Execution Score** — The mean execution score across all weeks in a cycle that have at least one data point.

**Tactic Streak** — For a given tactic, the number of consecutive past weeks in which the user fully completed that tactic's required checkpoints. Displayed as a badge next to the tactic name.

**Metric Progress** — For each metric target, the most recently logged value is compared to the target to show how close the user is.

---

## Behavioral Notes

- The application runs as a single page; navigation changes which view is visible without reloading
- Data is auto-saved whenever the user makes a change; there is no explicit save button for most interactions
- The app checks on load whether any recently completed cycles are missing a retrospective and surfaces a nudge if so
- All time references are relative to the local device clock; the app has no concept of time zones
- There is no user authentication, multi-user support, or data sync (except optional Notion integration noted in the README)

---

## What the Application Does Not Do

- No reminders or push notifications
- No collaboration or sharing
- No export to PDF or other formats
- No historical comparison between cycles (beyond the retro records)
- No AI or adaptive suggestions
- No mobile-optimized layout (designed for desktop browser use)
