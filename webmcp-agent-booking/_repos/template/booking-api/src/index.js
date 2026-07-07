// 運営用予約API。web/(参加者向け予約サイト)とagents/(WebMCP経由)からの予約操作、
// admin/(運営フロント)からのリセット操作を、この1つのAPIが受け付ける。
import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import {
  createReservation,
  getSeat,
  listReservations,
  listSeats,
  resetAll,
} from "./store.js";

const PORT = process.env.PORT ? Number(process.env.PORT) : 3001;
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || "gdg-io-osaka-2026";

const app = new Hono();

app.use(
  "*",
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "OPTIONS"],
    allowHeaders: ["Content-Type", "x-admin-password"],
  }),
);

async function requireAdminPassword(c, next) {
  const password = c.req.header("x-admin-password") ?? "";
  if (password !== ADMIN_PASSWORD) {
    return c.json({ error: "invalid_password" }, 401);
  }
  await next();
}

app.get("/api/seats", (c) => c.json({ seats: listSeats() }));

app.get("/api/seats/:id", (c) => {
  const seat = getSeat(c.req.param("id"));
  if (!seat) return c.json({ error: "seat_not_found" }, 404);
  return c.json({ seat });
});

app.get("/api/reservations", (c) => c.json({ reservations: listReservations() }));

app.post("/api/reservations", async (c) => {
  const body = await c.req.json().catch(() => ({}));
  const result = createReservation(body);
  if (result.error === "seat_not_found") return c.json(result, 404);
  if (result.error === "seat_already_reserved") return c.json(result, 409);
  return c.json(result, 201);
});

app.post("/api/admin/verify", async (c) => {
  const password = c.req.header("x-admin-password") ?? "";
  return c.json({ ok: password === ADMIN_PASSWORD });
});

app.post("/api/admin/reset", requireAdminPassword, (c) => {
  const result = resetAll();
  return c.json({ ok: true, ...result });
});

serve({ fetch: app.fetch, port: PORT }, (info) => {
  console.log(`運営用予約API: http://localhost:${info.port}`);
});
