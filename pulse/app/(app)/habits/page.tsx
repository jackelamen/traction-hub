import { HabitsClient } from "./habits-client";

export const metadata = { title: "Habits" };

export default function HabitsPage() {
  return (
    <div className="mx-auto w-full max-w-6xl px-5 py-8 md:py-12">
      <header className="mb-6 rounded-3xl border border-border/70 bg-card px-6 py-6 shadow-[0_18px_46px_rgba(20,24,45,0.07)]">
        <p className="text-xs font-semibold uppercase tracking-[0.14em] text-primary">
          Daily rhythm
        </p>
        <h1 className="mt-2 font-display text-3xl font-semibold tracking-tight md:text-4xl">
          Habits
        </h1>
        <p className="mt-2 max-w-xl text-sm text-muted-foreground">
          Build visual streaks, keep today simple, and make routines feel worth returning to.
        </p>
      </header>
      <HabitsClient />
    </div>
  );
}
