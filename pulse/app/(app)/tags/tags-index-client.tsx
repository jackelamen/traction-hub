"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { useTags } from "@/lib/lists/queries";
import { tagColor } from "@/lib/lists/tag-colors";

export function TagsIndexClient() {
  const tags = useTags();
  const [counts, setCounts] = useState<Record<string, number>>({});

  // Aggregate tag usage from tasks. Cheap because RLS already scopes it.
  useEffect(() => {
    (async () => {
      const supabase = createClient();
      const { data } = await supabase
        .from("tasks")
        .select("tags")
        .is("deleted_at", null);
      const map: Record<string, number> = {};
      const rows = (data ?? []) as Array<{ tags: string[] | null }>;
      for (const row of rows) {
        for (const t of (row.tags ?? []) as string[]) map[t] = (map[t] ?? 0) + 1;
      }
      setCounts(map);
    })();
  }, []);

  const rows = useMemo(() => {
    const known = new Set<string>(Object.keys(counts));
    for (const t of tags.data ?? []) known.add(t.name);
    return Array.from(known)
      .map((name) => ({
        name,
        explicitColor: tags.data?.find((x) => x.name === name)?.color ?? null,
        count: counts[name] ?? 0,
      }))
      .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
  }, [tags.data, counts]);

  if (rows.length === 0) {
    return (
      <div className="pulse-pane px-6 py-10 text-center text-sm text-muted-foreground">
        No tags yet. Add <span className="pulse-kbd">#tag</span> in a quick-add and they&apos;ll show up here.
      </div>
    );
  }

  return (
    <ul className="space-y-1">
      {rows.map(({ name, explicitColor, count }) => (
        <li key={name}>
          <Link href={`/tags/${encodeURIComponent(name)}`} className="pulse-row">
            <span
              className="h-2.5 w-2.5 rounded-full"
              style={{ backgroundColor: tagColor(name, explicitColor) }}
            />
            <span className="flex-1 truncate text-sm">#{name}</span>
            <span className="text-xs text-muted-foreground">{count}</span>
          </Link>
        </li>
      ))}
    </ul>
  );
}
