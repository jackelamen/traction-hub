"use client";

import { useEffect } from "react";
import { localDateKey } from "@/lib/habits/dates";
import { useTodayTasks } from "@/lib/tasks/queries";
import type { Task } from "@/lib/tasks/types";

const WORK_BRIDGE_KEY = "edgex_pulse_timeblocks_v1";

function localTimeLabel(iso: string) {
  const d = new Date(iso);
  const hours = String(d.getHours()).padStart(2, "0");
  const minutes = String(d.getMinutes()).padStart(2, "0");
  return `${hours}:${minutes}`;
}

function toBridgeTask(task: Task) {
  return {
    id: task.id,
    title: task.title,
    start_at: task.start_at,
    start: task.start_at ? localTimeLabel(task.start_at) : null,
    duration_minutes: task.duration_minutes,
    priority: task.priority,
    tags: task.tags ?? [],
    list_id: task.list_id,
  };
}

export function PulseWorkBridge() {
  const today = useTodayTasks();

  useEffect(() => {
    if (typeof window === "undefined" || !today.data) return;

    const payload = {
      version: 1,
      source: "pulse",
      date: localDateKey(new Date()),
      exported_at: new Date().toISOString(),
      tasks: today.data
        .filter((task) => task.start_at && !task.completed_at)
        .map(toBridgeTask)
        .sort((a, b) => String(a.start_at).localeCompare(String(b.start_at))),
    };

    window.localStorage.setItem(WORK_BRIDGE_KEY, JSON.stringify(payload));
    window.dispatchEvent(new CustomEvent("edgex:pulse-timeblocks-updated", { detail: payload }));
  }, [today.data]);

  return null;
}
