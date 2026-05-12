const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const NOTION_VERSION = "2022-06-28";

class PublicError extends Error {
  constructor(message: string, readonly status = 400) {
    super(message);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return json({}, 200);
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const body = await req.json().catch(() => ({}));
    const notionToken = firstString(
      body.notionToken,
      Deno.env.get("NOTION_TOKEN"),
      Deno.env.get("NOTION_API_KEY"),
    );
    const databaseId = firstString(body.databaseId, Deno.env.get("NOTION_DATABASE_ID"));
    const pageMapId = firstString(body.pageMapId);
    const properties = body.properties;

    if (!notionToken) throw new PublicError("Missing Notion token.", 400);
    if (!pageMapId && !databaseId) throw new PublicError("Missing Notion database id.", 400);
    if (!properties || typeof properties !== "object" || Array.isArray(properties)) {
      throw new PublicError("Missing Notion properties.", 400);
    }

    const isUpdate = Boolean(pageMapId);
    const notionRes = await fetch(`https://api.notion.com/v1/${isUpdate ? `pages/${encodeURIComponent(pageMapId)}` : "pages"}`, {
      method: isUpdate ? "PATCH" : "POST",
      headers: {
        Authorization: `Bearer ${notionToken}`,
        "Content-Type": "application/json",
        "Notion-Version": NOTION_VERSION,
      },
      body: JSON.stringify(isUpdate
        ? { properties }
        : { parent: { database_id: databaseId }, properties }),
    });

    const data = await parseJson(notionRes);
    if (!notionRes.ok) {
      return json({
        error: data.code || "notion_error",
        message: data.message || `Notion returned HTTP ${notionRes.status}`,
      }, notionRes.status);
    }

    return json({ pageId: data.id || pageMapId || null }, 200);
  } catch (error) {
    if (error instanceof PublicError) {
      return json({ error: error.message }, error.status);
    }
    console.error(error);
    return json({ error: "Could not sync with Notion." }, 500);
  }
});

function firstString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) return value.trim();
  }
  return "";
}

async function parseJson(res: Response) {
  const text = await res.text();
  if (!text) return {};
  try {
    return JSON.parse(text);
  } catch {
    return { message: text };
  }
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
