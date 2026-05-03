const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") || "";
const FROM_EMAIL = Deno.env.get("FINANCE_PIN_FROM_EMAIL") || "EDGEx <onboarding@resend.dev>";
const PIN_TTL_MINUTES = 5;
const MAX_ATTEMPTS = 5;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return json({}, 200);
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    assertConfigured();
    const authHeader = req.headers.get("Authorization") || "";
    const user = await getUser(authHeader);
    const body = await req.json().catch(() => ({}));

    if (body.action === "send") {
      return await sendPin(user);
    }
    if (body.action === "verify") {
      return await verifyPin(user, String(body.pin || ""));
    }
    return json({ error: "Unknown action" }, 400);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unexpected error";
    const status = message === "Unauthorized" ? 401 : 500;
    return json({ error: message }, status);
  }
});

function assertConfigured() {
  if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
    throw new Error("Finance PIN function is missing Supabase service configuration.");
  }
  if (!RESEND_API_KEY) {
    throw new Error("Finance PIN email is not configured. Add RESEND_API_KEY to Edge Function secrets.");
  }
}

async function getUser(authHeader: string) {
  if (!authHeader.startsWith("Bearer ")) throw new Error("Unauthorized");
  const res = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      apikey: SERVICE_ROLE_KEY,
      Authorization: authHeader,
    },
  });
  if (!res.ok) throw new Error("Unauthorized");
  const user = await res.json();
  if (!user?.id || !user?.email) throw new Error("Unauthorized");
  return { id: user.id as string, email: user.email as string };
}

async function sendPin(user: { id: string; email: string }) {
  const pin = randomPin();
  const pinHash = await sha256(`${user.id}:${pin}`);
  const expiresAt = new Date(Date.now() + PIN_TTL_MINUTES * 60 * 1000).toISOString();

  const upsertRes = await supabaseFetch("/rest/v1/finance_pin_challenges?on_conflict=user_id", {
    method: "POST",
    headers: { Prefer: "resolution=merge-duplicates,return=minimal" },
    body: JSON.stringify({
      user_id: user.id,
      email: user.email,
      pin_hash: pinHash,
      expires_at: expiresAt,
      attempts: 0,
      created_at: new Date().toISOString(),
    }),
  });
  if (!upsertRes.ok) throw new Error(`Could not store PIN challenge: ${await upsertRes.text()}`);

  const emailRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: user.email,
      subject: "Your EDGEx Finance PIN",
      html: `<p>Your EDGEx Finance PIN is:</p><p style="font-size:24px;font-weight:700;letter-spacing:4px">${pin}</p><p>This code expires in ${PIN_TTL_MINUTES} minutes.</p>`,
      text: `Your EDGEx Finance PIN is ${pin}. It expires in ${PIN_TTL_MINUTES} minutes.`,
    }),
  });
  if (!emailRes.ok) throw new Error(`Could not send PIN email: ${await emailRes.text()}`);

  return json({ sent: true, expiresInSeconds: PIN_TTL_MINUTES * 60 });
}

async function verifyPin(user: { id: string; email: string }, pin: string) {
  if (!/^\d{6}$/.test(pin)) return json({ verified: false, error: "Enter the 6-digit PIN." }, 400);

  const res = await supabaseFetch(`/rest/v1/finance_pin_challenges?user_id=eq.${encodeURIComponent(user.id)}&select=user_id,pin_hash,expires_at,attempts`, {
    method: "GET",
  });
  if (!res.ok) throw new Error(`Could not load PIN challenge: ${await res.text()}`);
  const rows = await res.json();
  const challenge = rows[0];
  if (!challenge) return json({ verified: false, error: "No active PIN. Send a new PIN." }, 400);
  if (new Date(challenge.expires_at).getTime() < Date.now()) {
    await deleteChallenge(user.id);
    return json({ verified: false, error: "PIN expired. Send a new PIN." }, 400);
  }
  if (Number(challenge.attempts || 0) >= MAX_ATTEMPTS) {
    await deleteChallenge(user.id);
    return json({ verified: false, error: "Too many attempts. Send a new PIN." }, 429);
  }

  const pinHash = await sha256(`${user.id}:${pin}`);
  if (pinHash !== challenge.pin_hash) {
    await supabaseFetch(`/rest/v1/finance_pin_challenges?user_id=eq.${encodeURIComponent(user.id)}`, {
      method: "PATCH",
      body: JSON.stringify({ attempts: Number(challenge.attempts || 0) + 1 }),
    });
    return json({ verified: false, error: "Incorrect PIN." }, 400);
  }

  await deleteChallenge(user.id);
  return json({ verified: true });
}

async function deleteChallenge(userId: string) {
  await supabaseFetch(`/rest/v1/finance_pin_challenges?user_id=eq.${encodeURIComponent(userId)}`, {
    method: "DELETE",
  });
}

async function supabaseFetch(path: string, init: RequestInit) {
  return fetch(`${SUPABASE_URL}${path}`, {
    ...init,
    headers: {
      apikey: SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      ...(init.headers || {}),
    },
  });
}

function randomPin() {
  const bytes = new Uint32Array(1);
  crypto.getRandomValues(bytes);
  return String(bytes[0] % 1_000_000).padStart(6, "0");
}

async function sha256(value: string) {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
