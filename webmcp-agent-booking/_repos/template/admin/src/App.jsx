import { useCallback, useEffect, useState } from "react";
import { fetchReservations, fetchSeats, resetSeats, verifyAdminPassword } from "./api.js";

function LoginForm({ onUnlock }) {
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [checking, setChecking] = useState(false);

  async function handleSubmit(event) {
    event.preventDefault();
    setChecking(true);
    setError("");
    const ok = await verifyAdminPassword(password);
    setChecking(false);
    if (ok) {
      onUnlock(password);
    } else {
      setError("パスワードが違います。");
    }
  }

  return (
    <form className="login-form" onSubmit={handleSubmit}>
      <h1>座席予約 運営管理</h1>
      <label htmlFor="password">管理者パスワード</label>
      <input
        id="password"
        type="password"
        value={password}
        onChange={(event) => setPassword(event.target.value)}
        autoFocus
      />
      <button type="submit" disabled={checking}>
        {checking ? "確認中..." : "ログイン"}
      </button>
      {error && <p className="error">{error}</p>}
    </form>
  );
}

function Dashboard({ password, onLock }) {
  const [seats, setSeats] = useState([]);
  const [reservations, setReservations] = useState([]);
  const [status, setStatus] = useState("");
  const [resetting, setResetting] = useState(false);

  const refresh = useCallback(async () => {
    const [seatList, reservationList] = await Promise.all([fetchSeats(), fetchReservations()]);
    setSeats(seatList);
    setReservations(reservationList);
  }, []);

  useEffect(() => {
    refresh();
    const timer = setInterval(refresh, 3000);
    return () => clearInterval(timer);
  }, [refresh]);

  async function handleReset() {
    if (!window.confirm("本当に全座席をリセットしますか？現在の予約は全て消えます。")) return;
    setResetting(true);
    setStatus("リセット中...");
    try {
      await resetSeats(password);
      setStatus("リセットしました。");
      await refresh();
    } catch (err) {
      setStatus(`リセットに失敗しました: ${err.message}`);
    } finally {
      setResetting(false);
    }
  }

  const reservedCount = seats.filter((seat) => seat.status === "reserved").length;

  return (
    <div className="dashboard">
      <header>
        <div className="header-row">
          <h1>座席予約 運営管理</h1>
          <button className="link" onClick={onLock}>
            ロック
          </button>
        </div>
        <p className="counts">
          予約済み {reservedCount} / {seats.length}
        </p>
        <button className="danger" onClick={handleReset} disabled={resetting}>
          {resetting ? "リセット中..." : "全座席をリセット"}
        </button>
        {status && <p className="status">{status}</p>}
      </header>

      <section className="seat-grid" aria-label="座席一覧">
        {seats.map((seat) => (
          <div
            key={seat.id}
            className={`seat ${seat.status}`}
            title={`${seat.id} / ¥${seat.price.toLocaleString()} / ${seat.tags.join(", ")}`}
          >
            {seat.id}
          </div>
        ))}
      </section>

      <section className="reservation-list" aria-label="予約一覧">
        <h2>予約一覧</h2>
        {reservations.length === 0 ? (
          <p className="empty">まだ予約はありません。</p>
        ) : (
          <ul>
            {reservations.map((reservation) => (
              <li key={reservation.seatId}>
                {reservation.seatId} — {reservation.displayName}
                {reservation.note ? `（${reservation.note}）` : ""}
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}

export default function App() {
  const [password, setPassword] = useState(null);

  if (!password) {
    return <LoginForm onUnlock={setPassword} />;
  }
  return <Dashboard password={password} onLock={() => setPassword(null)} />;
}
