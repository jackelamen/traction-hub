import { ListsIndexClient } from "./lists-index-client";

export const metadata = { title: "Lists" };

export default function ListsPage() {
  return (
    <div className="mx-auto w-full max-w-2xl px-5 py-8 md:py-10">
      <header className="mb-6">
        <h1 className="font-display text-3xl font-semibold tracking-tight md:text-4xl">Lists</h1>
        <p className="mt-1 text-sm text-muted-foreground">All your projects in one place.</p>
      </header>
      <ListsIndexClient />
    </div>
  );
}
