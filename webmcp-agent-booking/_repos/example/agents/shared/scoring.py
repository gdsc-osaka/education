"""座席の最終ランキングを決める。LLMは各軸の1-10点を提案するだけで、
集計・並び替えは完全にPythonで決定的に行う（最重要方針）。"""

from __future__ import annotations

from .models import EvaluationReport, RankedSeat, SeatCandidate

AXES = ("location", "price", "effect")
DEFAULT_SCORE = 5


def score_and_rank(
    candidates: list[SeatCandidate],
    reports: list[EvaluationReport],
) -> list[RankedSeat]:
    scores_by_axis: dict[str, dict[str, tuple[int, str]]] = {axis: {} for axis in AXES}
    for report in reports:
        if report.axis not in scores_by_axis:
            continue
        for axis_score in report.scores:
            scores_by_axis[report.axis][axis_score.seat_id] = (axis_score.score, axis_score.reason)

    ranked: list[RankedSeat] = []
    for candidate in candidates:
        if candidate.status != "available":
            continue

        axis_scores: dict[str, int] = {}
        reasons: list[str] = []
        for axis in AXES:
            score, reason = scores_by_axis[axis].get(candidate.seat_id, (DEFAULT_SCORE, ""))
            axis_scores[axis] = score
            if reason:
                reasons.append(reason)

        total = sum(axis_scores.values()) / len(AXES)
        ranked.append(
            RankedSeat(
                seat_id=candidate.seat_id,
                total_score=round(total, 2),
                axis_scores=axis_scores,
                reasons=reasons,
            )
        )

    ranked.sort(key=lambda seat: seat.total_score, reverse=True)
    return ranked
