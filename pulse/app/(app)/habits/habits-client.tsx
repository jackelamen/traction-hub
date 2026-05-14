"use client";

import { useMemo, useState } from "react";
import {
  Archive,
  BookOpen,
  CalendarCheck,
  Check,
  Dumbbell,
  Flame,
  HeartPulse,
  Moon,
  Pill,
  Plus,
  Repeat,
  Smile,
  Sparkles,
  Sprout,
  Sun,
  Target,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { HabitTodayRow } from "@/components/habits/habit-today-row";
import {
  useArchiveHabit,
  useCreateHabit,
  useHabits,
  useLast90HabitLogs,
  useToggleHabitLog,
  useUpdateHabit,
} from "@/lib/habits/queries";
import {
  completionMap,
  currentStreak,
  isHabitDueOn,
  localDateKey,
  longestStreak,
  monthCompletionRate,
  readDaysConfig,
} from "@/lib/habits/dates";
import { addDays, startOfDay } from "@/lib/date";
import type { Habit, HabitCadence, HabitLog } from "@/lib/habits/types";
import { cn } from "@/lib/utils";

const COLORS = ["#10b981", "#f25c2a", "#3b82f6", "#8b5cf6", "#f59e0b", "#ec4899"];
const WEEKDAYS = [
  { day: 1, label: "M" },
  { day: 2, label: "T" },
  { day: 3, label: "W" },
  { day: 4, label: "T" },
  { day: 5, label: "F" },
  { day: 6, label: "S" },
  { day: 0, label: "S" },
];

export function HabitsClient() {
  const habits = useHabits();
  const logs = useLast90HabitLogs();
  const allLogs = logs.data ?? [];
  const allHabits = habits.data ?? [];

  return (
    <div className="space-y-6">
      <HabitWeekStrip habits={allHabits} logs={allLogs} />
      <HabitTodayRow />
      <NewHabitForm />

      {allHabits.length === 0 ? (
        <div className="pulse-pane px-6 py-10 text-center text-sm text-muted-foreground">
          No habits yet.
        </div>
      ) : (
        <div className="grid gap-4 xl:grid-cols-2">
          {allHabits.map((habit) => (
            <HabitCard key={habit.id} habit={habit} logs={allLogs.filter((l) => l.habit_id === habit.id)} />
          ))}
        </div>
      )}
    </div>
  );
}

function HabitWeekStrip({ habits, logs }: { habits: Habit[]; logs: HabitLog[] }) {
  const today = startOfDay(new Date());
  const days = Array.from({ length: 7 }).map((_, i) => addDays(today, i - 3));
  const logMap = completionMap(logs);

  return (
    <section className="pulse-pane px-4 py-4">
      <div className="grid grid-cols-7 gap-2">
        {days.map((day) => {
          const key = localDateKey(day);
          const due = habits.filter((habit) => isHabitDueOn(habit, day)).length;
          const done = habits.filter((habit) => isHabitDueOn(habit, day) && (logMap.get(key) ?? 0) > 0).length;
          const ratio = due === 0 ? 0 : Math.round((done / due) * 100);
          const isToday = isSameDate(day, today);
          return (
            <div
              key={key}
              className={cn(
                "flex min-h-28 flex-col items-center justify-center rounded-3xl border px-2 py-3 text-center",
                isToday
                  ? "border-border bg-muted text-foreground"
                  : "border-transparent bg-transparent text-muted-foreground"
              )}
            >
              <div className="text-xs font-semibold">{day.toLocaleDateString(undefined, { weekday: "short" })}</div>
              <div className="mt-1 text-lg font-semibold">{day.getDate()}</div>
              <ProgressDot ratio={ratio} color={isToday ? "#304078" : "#64748b"} muted={due === 0} />
            </div>
          );
        })}
      </div>
    </section>
  );
}

function NewHabitForm() {
  const create = useCreateHabit();
  const [name, setName] = useState("");
  const [cadence, setCadence] = useState<HabitCadence>("daily");
  const [days, setDays] = useState<number[]>([1]);
  const [color, setColor] = useState(COLORS[0]);

  async function submit() {
    const title = name.trim();
    if (!title) return;
    await create.mutateAsync({
      name: title,
      cadence,
      cadence_config: cadence === "weekly" || cadence === "custom" ? { days } : {},
      color,
    });
    setName("");
    setCadence("daily");
    setDays([1]);
    setColor(COLORS[0]);
  }

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        submit();
      }}
      className="pulse-pane space-y-3 p-4"
    >
      <div className="flex items-center gap-2">
        <Plus className="h-4 w-4 text-muted-foreground" />
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="New habit"
          className="min-w-0 flex-1 bg-transparent text-sm outline-none"
        />
        <Button type="submit" size="sm" disabled={!name.trim() || create.isPending}>
          Create
        </Button>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <Segment value={cadence} onChange={setCadence} />
        {(cadence === "weekly" || cadence === "custom") && (
          <DayPicker days={days} onChange={setDays} />
        )}
        <div className="ml-auto flex items-center gap-1">
          {COLORS.map((c) => (
            <button
              key={c}
              type="button"
              onClick={() => setColor(c)}
              className={cn("h-5 w-5 rounded-full ring-2", color === c ? "ring-foreground/30" : "ring-transparent")}
              style={{ backgroundColor: c }}
              aria-label={`Color ${c}`}
            />
          ))}
        </div>
      </div>
    </form>
  );
}

function Segment({
  value,
  onChange,
}: {
  value: HabitCadence;
  onChange: (value: HabitCadence) => void;
}) {
  const options: HabitCadence[] = ["daily", "weekdays", "weekly", "custom"];
  return (
    <div className="flex rounded-md border border-border p-0.5">
      {options.map((option) => (
        <button
          key={option}
          type="button"
          onClick={() => onChange(option)}
          className={cn(
            "rounded px-2.5 py-1 text-xs capitalize transition-colors",
            value === option ? "bg-muted text-foreground" : "text-muted-foreground hover:bg-muted/50"
          )}
        >
          {option}
        </button>
      ))}
    </div>
  );
}

function DayPicker({ days, onChange }: { days: number[]; onChange: (days: number[]) => void }) {
  function toggle(day: number) {
    const next = days.includes(day) ? days.filter((d) => d !== day) : [...days, day];
    onChange(next.length > 0 ? next : [day]);
  }
  return (
    <div className="flex items-center gap-1">
      {WEEKDAYS.map(({ day, label }) => (
        <button
          key={`${day}-${label}`}
          type="button"
          onClick={() => toggle(day)}
          className={cn(
            "grid h-7 w-7 place-items-center rounded-full text-xs transition-colors",
            days.includes(day) ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"
          )}
        >
          {label}
        </button>
      ))}
    </div>
  );
}

function HabitCard({ habit, logs }: { habit: Habit; logs: HabitLog[] }) {
  const update = useUpdateHabit();
  const archive = useArchiveHabit();
  const toggle = useToggleHabitLog();
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(habit.name);
  const todayDone = completionMap(logs).has(localDateKey(new Date()));
  const color = habit.color || "#10b981";
  const Icon = habitIcon(habit);
  const stats = useMemo(
    () => ({
      current: currentStreak(habit, logs),
      longest: longestStreak(habit, logs),
      rate: monthCompletionRate(habit, logs),
    }),
    [habit, logs]
  );

  function commitName() {
    const next = draft.trim();
    setEditing(false);
    if (next && next !== habit.name) update.mutate({ id: habit.id, patch: { name: next } });
  }

  return (
    <article className="overflow-hidden rounded-3xl border border-border/70 bg-card shadow-[0_16px_38px_rgba(20,24,45,0.07)] transition-transform hover:-translate-y-0.5 hover:shadow-[0_22px_48px_rgba(20,24,45,0.1)]">
      <div className="flex items-center gap-4 border-b border-border/70 px-5 py-4">
        <div
          className="grid h-14 w-14 shrink-0 place-items-center rounded-full text-white shadow-[0_14px_28px_rgba(20,24,45,0.14)]"
          style={{
            background: `linear-gradient(135deg, ${color}, ${mixWithWhite(color, 0.25)})`,
          }}
        >
          <Icon className="h-7 w-7" />
        </div>

        <div className="min-w-0 flex-1">
          {editing ? (
            <input
              autoFocus
              value={draft}
              onChange={(e) => setDraft(e.target.value)}
              onBlur={commitName}
              onKeyDown={(e) => {
                if (e.key === "Enter") commitName();
                if (e.key === "Escape") {
                  setDraft(habit.name);
                  setEditing(false);
                }
              }}
              className="w-full bg-transparent font-display text-xl font-semibold outline-none"
            />
          ) : (
            <button
              type="button"
              onClick={() => setEditing(true)}
              className="block truncate font-display text-xl font-semibold"
            >
              {habit.name}
            </button>
          )}
          <div className="mt-1 flex flex-wrap items-center gap-2 text-xs capitalize text-muted-foreground">
            <span>{cadenceLabel(habit)}</span>
            <span className="h-1 w-1 rounded-full bg-muted-foreground/30" />
            <span>Target {habit.target_per_period}</span>
          </div>
        </div>

        <button
          type="button"
          onClick={() => toggle.mutate({ habitId: habit.id })}
          className={cn(
            "grid h-12 w-12 shrink-0 place-items-center rounded-full border transition-colors",
            todayDone ? "border-transparent text-white" : "border-muted bg-muted/70 text-transparent"
          )}
          style={todayDone ? { backgroundColor: color } : undefined}
          aria-label={todayDone ? `Unlog ${habit.name}` : `Log ${habit.name}`}
        >
          {todayDone && <Check className="h-4 w-4" />}
        </button>

        <button
          type="button"
          onClick={() => archive.mutate(habit.id)}
          className="rounded-xl p-2 text-muted-foreground hover:bg-muted hover:text-foreground"
          aria-label="Archive habit"
        >
          <Archive className="h-4 w-4" />
        </button>
      </div>

      <div className="space-y-5 p-5">
        <div className="flex items-center gap-4">
          <ProgressRing value={stats.rate} color={color} />
          <div>
            <div className="font-display text-2xl font-semibold">{stats.rate}%</div>
            <div className="text-xs text-muted-foreground">completion this month</div>
          </div>
        </div>
        <Heatmap habit={habit} logs={logs} />
        <div className="grid grid-cols-3 gap-2">
          <Stat icon={<Flame className="h-3.5 w-3.5" />} label="Current" value={`${stats.current}`} />
          <Stat icon={<Target className="h-3.5 w-3.5" />} label="Longest" value={`${stats.longest}`} />
          <Stat icon={<Repeat className="h-3.5 w-3.5" />} label="Month" value={`${stats.rate}%`} />
        </div>
      </div>
    </article>
  );
}

function ProgressDot({ ratio, color, muted }: { ratio: number; color: string; muted: boolean }) {
  return (
    <div
      className="mt-3 grid h-10 w-10 place-items-center rounded-full"
      style={{
        background: muted
          ? "hsl(var(--muted))"
          : `conic-gradient(${color} ${ratio}%, hsl(var(--muted)) 0)`,
      }}
    >
      <div className="h-7 w-7 rounded-full bg-card" />
    </div>
  );
}

function ProgressRing({ value, color }: { value: number; color: string }) {
  return (
    <div
      className="grid h-20 w-20 shrink-0 place-items-center rounded-full"
      style={{ background: `conic-gradient(${color} ${value}%, hsl(var(--muted)) 0)` }}
    >
      <div className="grid h-14 w-14 place-items-center rounded-full bg-card text-xs font-semibold">
        {value}%
      </div>
    </div>
  );
}

function Heatmap({ habit, logs }: { habit: Habit; logs: HabitLog[] }) {
  const today = startOfDay(new Date());
  const done = completionMap(logs);
  const days = Array.from({ length: 90 }).map((_, i) => addDays(today, i - 89));
  return (
    <div className="grid grid-cols-[repeat(30,minmax(0,1fr))] gap-1">
      {days.map((day) => {
        const key = localDateKey(day);
        const due = isHabitDueOn(habit, day);
        const complete = (done.get(key) ?? 0) > 0;
        return (
          <div
            key={key}
            title={`${key}${complete ? " logged" : ""}`}
            className={cn(
              "aspect-square rounded-[3px]",
              !due && "bg-transparent",
              due && !complete && "bg-muted",
              complete && "bg-emerald-500"
            )}
            style={complete && habit.color ? { backgroundColor: habit.color } : undefined}
          />
        );
      })}
    </div>
  );
}

function Stat({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-border/60 bg-muted/40 px-3 py-3">
      <div className="flex items-center gap-1 text-xs text-muted-foreground">
        {icon}
        {label}
      </div>
      <div className="mt-1 font-display text-xl font-semibold">{value}</div>
    </div>
  );
}

function habitIcon(habit: Habit) {
  const name = `${habit.icon ?? ""} ${habit.name}`.toLowerCase();
  if (name.includes("med") || name.includes("pill")) return Pill;
  if (name.includes("exercise") || name.includes("workout") || name.includes("gym")) return Dumbbell;
  if (name.includes("journal") || name.includes("read")) return BookOpen;
  if (name.includes("sleep") || name.includes("night")) return Moon;
  if (name.includes("morning") || name.includes("rise")) return Sun;
  if (name.includes("health") || name.includes("heart")) return HeartPulse;
  if (name.includes("plan") || name.includes("calendar")) return CalendarCheck;
  if (name.includes("mood") || name.includes("smile")) return Smile;
  if (name.includes("meditate") || name.includes("mind")) return Sparkles;
  return Sprout;
}

function isSameDate(a: Date, b: Date) {
  return localDateKey(a) === localDateKey(b);
}

function mixWithWhite(hex: string, amount: number) {
  const raw = hex.replace("#", "");
  if (raw.length !== 6) return hex;
  const n = Number.parseInt(raw, 16);
  const r = (n >> 16) & 255;
  const g = (n >> 8) & 255;
  const b = n & 255;
  const mix = (v: number) => Math.round(v + (255 - v) * amount);
  return `rgb(${mix(r)}, ${mix(g)}, ${mix(b)})`;
}

function cadenceLabel(habit: Habit) {
  if (habit.cadence === "weekly" || habit.cadence === "custom") {
    const days = readDaysConfig(habit);
    if (days.length > 0) {
      const names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      return days.map((d) => names[d]).join(", ");
    }
  }
  return habit.cadence;
}
