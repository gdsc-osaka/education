// ==============================
// 既存の予約サイトロジック（API通信・描画・フォーム送信）
// ==============================
// 座席・予約データは運営用予約API(booking-api)から取得する。
// config.js の BOOKING_API_BASE_URL を変更すれば、複数PCから同じ座席プールを共有できる。

const API_BASE = window.BOOKING_API_BASE_URL ?? "http://localhost:3001";

async function fetchSeats() {
  const res = await fetch(`${API_BASE}/api/seats`);
  const data = await res.json();
  return data.seats;
}

async function fetchReservations() {
  const res = await fetch(`${API_BASE}/api/reservations`);
  const data = await res.json();
  return data.reservations;
}

async function reserveSeat({ seatId, displayName, note }) {
  const res = await fetch(`${API_BASE}/api/reservations`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ seatId, displayName, note }),
  });
  const data = await res.json();
  return { ok: res.ok, status: res.status, data };
}

const seatGrid = document.getElementById("seatGrid");
const seatIdInput = document.getElementById("seatIdInput");
const selectedSeatLabel = document.getElementById("selectedSeatLabel");
const submitButton = document.getElementById("submitButton");
const reservationForm = document.getElementById("reservationForm");
const reservationStatus = document.getElementById("reservationStatus");
const reservationList = document.getElementById("reservationList");

function seatLabel(seat) {
  const positionLabel = { aisle: "通路側", window: "窓側", center: "中央" }[seat.position] ?? seat.position;
  return `${seat.id}（${seat.section} / ${positionLabel} / ¥${seat.price.toLocaleString()}）`;
}

function selectSeat(seat) {
  if (seat.status === "reserved") return;
  seatIdInput.value = seat.id;
  selectedSeatLabel.textContent = `選択中: ${seatLabel(seat)}`;
  submitButton.disabled = false;
}

async function renderSeats() {
  const seats = await fetchSeats();
  seatGrid.innerHTML = "";
  for (const seat of seats) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `seat ${seat.status}`;
    button.textContent = seat.id;
    button.title = seatLabel(seat);
    button.disabled = seat.status === "reserved";
    button.addEventListener("click", () => selectSeat(seat));
    seatGrid.appendChild(button);
  }
  return seats;
}

async function renderReservations() {
  const reservations = await fetchReservations();
  reservationList.innerHTML = "";
  for (const reservation of reservations) {
    const li = document.createElement("li");
    li.textContent = `${reservation.seatId} — ${reservation.displayName}${reservation.note ? `（${reservation.note}）` : ""}`;
    reservationList.appendChild(li);
  }
  return reservations;
}

async function refreshAll() {
  await renderSeats();
  await renderReservations();
}

reservationForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const seatId = seatIdInput.value;
  const displayName = document.getElementById("displayNameInput").value;
  const note = document.getElementById("noteInput").value;

  const resultPromise = reserveSeat({ seatId, displayName, note }).then(({ ok, data }) => {
    if (ok) {
      reservationStatus.textContent = `${seatId} を予約しました。`;
      reservationStatus.className = "reservation-status success";
      reservationForm.reset();
      submitButton.disabled = true;
      selectedSeatLabel.textContent = "座席を選択してください";
    } else {
      reservationStatus.textContent =
        data.error === "seat_already_reserved" ? `${seatId} は既に予約済みです。` : "予約に失敗しました。";
      reservationStatus.className = "reservation-status error";
    }
    return { ok, seatId, error: data.error ?? null };
  });

  // WebMCP宣言型APIでエージェントから呼ばれた場合は respondWith で結果を返す
  if (event.agentInvoked && typeof event.respondWith === "function") {
    event.respondWith(resultPromise);
  }

  const result = await resultPromise;
  await refreshAll();
  return result;
});

refreshAll();

// ==============================
// WebMCP 命令型API: エージェントから呼び出せるツールを登録する
// ==============================

function modelContext() {
  return document.modelContext ?? null;
}

function registerImperativeWebMcpTools() {
  const ctx = modelContext();
  if (!ctx) {
    console.warn("WebMCP: document.modelContext が見つかりません。@mcp-b/global の読み込みを確認してください。");
    return;
  }

  // TODO: 命令型WebMCP API を実装する。
  // ctx.registerTool({ name, description, inputSchema, execute }) を使って、
  // 次の3つのツールを登録する:
  //   - list_available_seats({ tag? }) : 空席一覧を返す（fetchSeats を使う）
  //   - get_seat_detail({ seatId })     : 1座席の詳細を返す
  //   - list_reservations()             : 予約済み一覧を返す（fetchReservations を使う）
}

registerImperativeWebMcpTools();
