import { createClient } from "@/lib/supabase/server";
import { displayNameForUser } from "@/lib/profile/display";
import { formatDateLong } from "@/lib/utils";
import { TodayClient } from "./today-client";

export const metadata = {
  title: "Today",
};

export default async function TodayPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const today = new Date();
  const greeting = greetingFor(today);
  const displayName = displayNameForUser(user);
  const firstName = displayName?.split(/\s+/)[0] ?? null;

  return (
    <div className="mx-auto w-full max-w-6xl px-5 py-7 md:px-7 md:py-10">
      <header className="mb-7 overflow-hidden rounded-3xl border border-border/70 bg-card shadow-[0_18px_46px_rgba(20,24,45,0.07)]">
        <div className="border-l-4 border-primary px-5 py-5 md:px-7">
          <p className="text-xs font-semibold uppercase tracking-[0.14em] text-primary">
            {formatDateLong(today)}
          </p>
          <h1 className="mt-2 font-display text-3xl font-semibold leading-tight tracking-tight text-foreground md:text-4xl">
            {greeting}
            {firstName ? `, ${firstName}` : ""}
          </h1>
          <p className="mt-2 max-w-2xl text-sm leading-6 text-muted-foreground">
            A clear view of what is timed, what matters most, and what is still flexible.
          </p>
        </div>
      </header>

      <TodayClient />
    </div>
  );
}

function greetingFor(d: Date) {
  const h = d.getHours();
  if (h < 5) return "Still up";
  if (h < 12) return "Good morning";
  if (h < 17) return "Good afternoon";
  return "Good evening";
}
