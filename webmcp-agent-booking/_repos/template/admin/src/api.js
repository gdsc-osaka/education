const API_BASE = import.meta.env.VITE_BOOKING_API_URL ?? "http://localhost:3001";

export async function fetchSeats() {
  const res = await fetch(`${API_BASE}/api/seats`);
  const data = await res.json();
  return data.seats;
}

export async function fetchReservations() {
  const res = await fetch(`${API_BASE}/api/reservations`);
  const data = await res.json();
  return data.reservations;
}

export async function verifyAdminPassword(password) {
  const res = await fetch(`${API_BASE}/api/admin/verify`, {
    method: "POST",
    headers: { "x-admin-password": password },
  });
  const data = await res.json();
  return data.ok === true;
}

export async function resetSeats(password) {
  const res = await fetch(`${API_BASE}/api/admin/reset`, {
    method: "POST",
    headers: { "x-admin-password": password },
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data.error ?? "reset_failed");
  }
  return data;
}
