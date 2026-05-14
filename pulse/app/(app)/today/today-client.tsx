"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  CalendarClock,
  ChevronDown,
  Flag,
  ListChecks,
  Sparkles,
  Timer,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { QuickAdd } from "@/components/tasks/quick-add";
import { TaskList } from "@/components/tasks/task-list";
import { TaskRow } from "@/components/tasks/task-row";
import { HabitTodayRow } from "@/components/habits/habit-today-row";
import {
  useTodayTasks,
  useCompletedTodayTasks,
  useLeftoverTasks,
  useRescheduleLeftovers,
} from "@/lib/tasks/queries";
import { useLast7FocusSessions } from "@/lib/focus/queries";
import { useHabits, useTodayHabitLogs } from "@/lib/habits/queries";
import { isHabitDueOn } from "@/lib/habits/dates";
import { isSameDay } from "@/lib/date";
import type { Task } from "@/lib/tasks/types";

export function TodayClient() {
  const today = useTodayTasks();
  const completedToday = useCompletedTodayTasks();
  const leftovers = useLeftoverTasks();
  const focusSessions = useLast7FocusSessions();
  const habits = useHabits();
  const habitLogs = useTodayHabitLogs();
  const reschedule = useRescheduleLeftovers();
  const [intention, setIntention] = useState("");
  const [showDone, setShowDone] = useState(false);

  const { scheduled, anytime } = useMemo(() => groupToday(today.data ?? []), [today.data]);
  const priorityTasks = useMemo(
    () =>
      (today.data ?? [])
        .filter((task) => task.priority >= 2)
        .sort((a, b) => b.priority - a.priority || timeValue(a) - timeValue(b))
        .slice(0, 5),
    [today.data]
  );
  const priorityIds = useMemo(() => new Set(priorityTasks.map((task) => task.id)), [priorityTasks]);
  const flexibleTasks = useMemo(
    () => anytime.filter((task) => !priorityIds.has(task.id)),
    [anytime, priorityIds]
  );
  const done = completedToday.data ?? [];
  const dueHabits = (habits.data ?? []).filter((habit) => isHabitDueOn(habit, new Date()));
  const doneHabits = (habitLogs.data ?? []).map((log) => ({
    ...log,
    name: habits.data?.find((habit) => habit.id === log.habit_id)?.name ?? "Habit",
  }));

  return (
    <div className="space-y-6">
      {(leftovers.data ?? []).length > 0 && (
        <LeftoverSection
          tasks={leftovers.data!}
          onBulk={(target) =>
            reschedule.mutate({ ids: leftovers.data!.map((t) => t.id), target })
          }
          pending={reschedule.isPending}
        />
      )}

      <DashboardSummary
        scheduledCount={scheduled.length}
        priorityCount={priorityTasks.length}
        habitCount={dueHabits.length}
        doneCount={done.length}
      />

      <section className="grid items-start gap-5 xl:grid-cols-[minmax(0,1fr)_380px]">
        <div className="space-y-5">
          <section className="pulse-pane p-4">
            <label className="flex items-center gap-2 text-xs font-medium uppercase tracking-wider text-muted-foreground">
              <Sparkles className="h-3.5 w-3.5" />
              Morning intention
            </label>
            <Input
              value={intention}
              onChange={(e) => setIntention(e.target.value)}
              placeholder="One sentence to anchor the day..."
              className="mt-2 border-0 px-0 text-base shadow-none focus-visible:ring-0"
            />
          </section>

          <PriorityPanel tasks={priorityTasks} />
          <TodayTimeline tasks={scheduled} />
          <AnytimePanel tasks={flexibleTasks} doneCount={done.length} />
        </div>

        <aside className="space-y-5">
          {dueHabits.length > 0 && (
            <section className="pulse-pane p-4">
              <SectionHeader>Habits due today</SectionHeader>
              <HabitTodayRow compact />
            </section>
          )}
          <FocusStats sessions={focusSessions.data ?? []} />
          <section>
            <SectionHeader>Quick capture</SectionHeader>
            <QuickAdd placeholder="Add task, time, duration, or tag" />
          </section>
        </aside>
      </section>

      {(done.length > 0 || doneHabits.length > 0) && (
        <section>
          <button
            type="button"
            onClick={() => setShowDone((v) => !v)}
            className="flex w-full items-center justify-between rounded-md px-2 py-1.5 text-xs font-semibold uppercase tracking-wider text-muted-foreground hover:bg-muted/50"
          >
            <span>
              Done today · {done.length} tasks · {doneHabits.length} habits
            </span>
            <ChevronDown
              className={`h-3.5 w-3.5 transition-transform ${showDone ? "rotate-180" : ""}`}
            />
          </button>
          {showDone && (
            <div className="mt-1 space-y-3">
              {done.length > 0 && (
                <ul className="space-y-0.5">
                  {done.map((t) => (
                    <TaskRow key={t.id} task={t} dense />
                  ))}
                </ul>
              )}
              {doneHabits.length > 0 && (
                <ul className="space-y-1 px-2">
                  {doneHabits.map((habit) => (
                    <li
                      key={habit.id}
                      className="flex items-center gap-2 rounded-md bg-muted/50 px-3 py-2 text-sm"
                    >
                      <span className="h-2 w-2 rounded-full bg-emerald-500" />
                      <span className="flex-1 truncate">{habit.name}</span>
                      <span className="text-xs text-muted-foreground">Habit</span>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          )}
        </section>
      )}
    </div>
  );
}

function DashboardSummary({
  scheduledCount,
  priorityCount,
  habitCount,
  doneCount,
}: {
  scheduledCount: number;
  priorityCount: number;
  habitCount: number;
  doneCount: number;
}) {
  const items = [
    { label: "Timed tasks", value: scheduledCount, icon: CalendarClock },
    { label: "Priorities", value: priorityCount, icon: Flag },
    { label: "Habits", value: habitCount, icon: ListChecks },
    { label: "Done", value: doneCount, icon: Timer },
  ];

  return (
    <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
      {items.map(({ label, value, icon: Icon }, index) => (
        <div
          key={label}
          className={`pulse-pane flex items-center gap-3 px-4 py-3 ${
            index === 0 ? "border-primary/30 bg-primary/5" : "bg-card"
          }`}
        >
          <div className="grid h-11 w-11 place-items-center rounded-2xl bg-primary/10 text-primary">
            <Icon className="h-4 w-4" />
          </div>
          <div>
            <div className="font-display text-3xl font-semibold leading-none text-foreground">{value}</div>
            <div className="mt-1 text-xs font-medium text-muted-foreground">{label}</div>
          </div>
        </div>
      ))}
    </section>
  );
}

function PriorityPanel({ tasks }: { tasks: Task[] }) {
  return (
    <section className="pulse-pane p-4">
      <SectionHeader>Priority queue</SectionHeader>
      {tasks.length === 0 ? (
        <p className="px-1 py-4 text-sm text-muted-foreground">
          No high-priority tasks in today’s plan.
        </p>
      ) : (
        <ul className="space-y-2">
          {tasks.map((task) => (
            <li
              key={task.id}
              className="rounded-2xl border border-border bg-card px-3 py-3 shadow-sm"
            >
              <div className="flex items-start gap-3">
                <span
                  className={`mt-1 h-3 w-3 shrink-0 rounded-full ring-4 ${
                    task.priority >= 3
                      ? "bg-rose-500 ring-rose-500/15"
                      : "bg-amber-400 ring-amber-400/20"
                  }`}
                />
                <div className="min-w-0 flex-1">
                  <div className="truncate text-sm font-semibold text-foreground">{task.title}</div>
                  <div className="mt-1 flex flex-wrap items-center gap-2 text-[11px] font-medium text-muted-foreground">
                    {task.start_at && <span>{formatTaskTime(task)}</span>}
                    <span>{task.priority >= 3 ? "High priority" : "Medium priority"}</span>
                    {task.tags?.slice(0, 2).map((tag) => <span key={tag}>#{tag}</span>)}
                  </div>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

function TodayTimeline({ tasks }: { tasks: Task[] }) {
  return (
    <section className="pulse-pane p-4">
      <SectionHeader>Today timeline</SectionHeader>
      {tasks.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-border bg-muted/30 px-4 py-8 text-sm text-muted-foreground">
          No timed tasks yet. Add a time in quick-add or task details to build the day’s timeline.
        </div>
      ) : (
        <ol className="relative space-y-3 before:absolute before:left-[4.25rem] before:top-2 before:h-[calc(100%-1rem)] before:w-px before:bg-border">
          {tasks.map((task) => (
            <li key={task.id} className="grid grid-cols-[4rem_minmax(0,1fr)] gap-4">
              <div className="pt-3 text-right text-xs font-medium text-muted-foreground">
                {formatTaskTime(task)}
              </div>
              <div className="relative">
                <span className="absolute -left-[1.15rem] top-4 h-2.5 w-2.5 rounded-full bg-primary ring-4 ring-background" />
                <ul>
                  <TaskRow task={task} dense />
                </ul>
                <div className="mt-1 px-3 text-xs text-muted-foreground">
                  {task.duration_minutes ? `${task.duration_minutes} minutes` : "No duration set"}
                </div>
              </div>
            </li>
          ))}
        </ol>
      )}
    </section>
  );
}

function AnytimePanel({ tasks, doneCount }: { tasks: Task[]; doneCount: number }) {
  return (
    <section className="pulse-pane p-4">
      <SectionHeader>Flexible today</SectionHeader>
      <TaskList
        tasks={tasks}
        sortable
        emptyMessage={
          doneCount === 0 ? (
            <span>
              Nothing flexible yet. Press <span className="pulse-kbd">N</span> or use quick capture.
            </span>
          ) : (
            <span>No flexible tasks left for today.</span>
          )
        }
      />
    </section>
  );
}

function FocusStats({
  sessions,
}: {
  sessions: Array<{ started_at: string; actual_minutes: number | null; planned_minutes: number }>;
}) {
  const today = new Date();
  const todayMinutes = sessions
    .filter((s) => isSameDay(new Date(s.started_at), today))
    .reduce((sum, s) => sum + (s.actual_minutes ?? s.planned_minutes), 0);
  const weekMinutes = sessions.reduce((sum, s) => sum + (s.actual_minutes ?? s.planned_minutes), 0);

  if (todayMinutes === 0 && weekMinutes === 0) return null;

  return (
    <section className="pulse-pane flex flex-wrap items-center gap-3 px-4 py-3">
      <div className="flex h-9 w-9 items-center justify-center rounded-full bg-primary/10 text-primary">
        <Timer className="h-4 w-4" />
      </div>
      <div>
        <div className="text-sm font-medium">{todayMinutes} focus minutes today</div>
        <div className="text-xs text-muted-foreground">{weekMinutes} minutes in the last 7 days</div>
      </div>
    </section>
  );
}

function SectionHeader({ children }: { children: React.ReactNode }) {
  return <h2 className="pulse-section-label">{children}</h2>;
}

function LeftoverSection({
  tasks,
  onBulk,
  pending,
}: {
  tasks: Task[];
  onBulk: (target: "today" | "tomorrow" | "inbox") => void;
  pending: boolean;
}) {
  return (
    <section className="rounded-xl border border-amber-300/50 bg-amber-50 p-4 dark:border-amber-500/30 dark:bg-amber-500/5">
      <div className="mb-3 flex flex-wrap items-center gap-2">
        <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-amber-700 dark:text-amber-300">
          <AlertTriangle className="h-3.5 w-3.5" />
          Leftover from yesterday · {tasks.length}
        </div>
        <div className="ml-auto flex flex-wrap items-center gap-1.5">
          <Button size="sm" variant="outline" disabled={pending} onClick={() => onBulk("today")}>
            All to today
          </Button>
          <Button size="sm" variant="outline" disabled={pending} onClick={() => onBulk("tomorrow")}>
            Push to tomorrow
          </Button>
          <Button size="sm" variant="ghost" disabled={pending} onClick={() => onBulk("inbox")}>
            Send to inbox
          </Button>
        </div>
      </div>
      <TaskList tasks={tasks} dense />
    </section>
  );
}

/* ------------------------------------------------------------------ */
/* Grouping                                                            */
/* ------------------------------------------------------------------ */

function groupToday(tasks: Task[]) {
  const scheduled: Task[] = [];
  const anytime: Task[] = [];

  for (const t of tasks) {
    if (t.start_at) scheduled.push(t);
    else anytime.push(t);
  }

  scheduled.sort((a, b) => timeValue(a) - timeValue(b));
  anytime.sort((a, b) => b.priority - a.priority || timeValue(a) - timeValue(b));

  return { scheduled, anytime };
}

function timeValue(task: Task) {
  return task.start_at ? new Date(task.start_at).getTime() : Number.MAX_SAFE_INTEGER;
}

function formatTaskTime(task: Task) {
  if (!task.start_at) return "Anytime";
  return new Date(task.start_at).toLocaleTimeString(undefined, {
    hour: "numeric",
    minute: "2-digit",
  });
}
