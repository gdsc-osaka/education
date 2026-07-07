// インメモリの座席・予約ストア。resetAll() で運営が任意タイミングで初期状態に戻せる。
import { createSeedSeats } from "./seed.js";

let seats = createSeedSeats();
let reservations = [];

export function listSeats() {
  return seats;
}

export function getSeat(seatId) {
  return seats.find((seat) => seat.id === seatId) ?? null;
}

export function listReservations() {
  return reservations;
}

export function createReservation({ seatId, displayName, note }) {
  const seat = getSeat(seatId);
  if (!seat) return { error: "seat_not_found" };
  if (seat.status === "reserved") return { error: "seat_already_reserved" };

  seat.status = "reserved";
  seat.reservedBy = displayName || "ゲスト";
  const reservation = {
    seatId,
    displayName: seat.reservedBy,
    note: note || "",
    reservedAt: new Date().toISOString(),
  };
  reservations.push(reservation);
  return { reservation, seat };
}

export function resetAll() {
  seats = createSeedSeats();
  reservations = [];
  return { seatCount: seats.length };
}
