"""ランキング上位から順に実際の予約を試みる。最大何回まで試すか・
どうなったら成功とみなすか・失敗時のメッセージは全てPython(shared/reservation.py)が決める。"""

import json

from google.adk import Context
from google.adk.agents.remote_a2a_agent import RemoteA2aAgent

from agents._common import remote_agent_card_url
from agents.shared.models import RankedSeat, ReservationAttemptResult, ReservationOutcome
from agents.shared.reservation import (
    MAX_ATTEMPTS,
    build_failure_message,
    build_success_message,
    confirm_reservation,
)

DEFAULT_DISPLAY_NAME = "AI予約エージェント"

reservation_remote = RemoteA2aAgent(
    name="reservation_remote",
    agent_card=remote_agent_card_url("RESERVATION_A2A_URL", "http://localhost:8105"),
    description="宣言型WebMCPフォームtool(reserve_seat)で実際に1席予約するspecialist。",
    output_schema=ReservationAttemptResult,
    use_legacy=False,
)


def _build_reservation_input(seat_id: str, note: str) -> str:
    payload = {"seat_id": seat_id, "display_name": DEFAULT_DISPLAY_NAME, "note": note}
    return json.dumps(payload, ensure_ascii=False)


def _coerce_attempt(value) -> ReservationAttemptResult | None:
    try:
        if isinstance(value, ReservationAttemptResult):
            return value
        if isinstance(value, dict):
            return ReservationAttemptResult.model_validate(value)
        if isinstance(value, str):
            return ReservationAttemptResult.model_validate(json.loads(value))
    except (json.JSONDecodeError, ValueError):
        pass
    return None


async def reserve_with_retry(ctx: Context, ranked_seats: list[RankedSeat]) -> ReservationOutcome:
    if ranked_seats and isinstance(ranked_seats[0], dict):
        ranked_seats = [RankedSeat.model_validate(r) for r in ranked_seats]

    note = ctx.state.get("seat_preference", {}).get("free_text", "")

    attempted: list[str] = []
    for candidate in ranked_seats[:MAX_ATTEMPTS]:
        attempted.append(candidate.seat_id)
        raw_result = await ctx.run_node(
            reservation_remote, _build_reservation_input(candidate.seat_id, note)
        )
        attempt = _coerce_attempt(raw_result)
        if attempt and confirm_reservation(candidate.seat_id, attempt.reservations_snapshot):
            outcome = ReservationOutcome(
                status="success",
                seat_id=candidate.seat_id,
                message=build_success_message(candidate.seat_id, candidate.reasons),
                attempts=attempted,
            )
            ctx.state["reservation_outcome"] = outcome.model_dump()
            return outcome

    outcome = ReservationOutcome(
        status="failed",
        seat_id=None,
        message=build_failure_message(attempted),
        attempts=attempted,
    )
    ctx.state["reservation_outcome"] = outcome.model_dump()
    return outcome
