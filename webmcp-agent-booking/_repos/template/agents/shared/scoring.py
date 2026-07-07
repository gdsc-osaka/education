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
    # TODO: reports (location/price/effect の3 EvaluationReport) から seat_id ごとの
    # 軸別スコアを集め、available な candidate ごとに3軸の平均を total_score として
    # RankedSeat を作る。スコアが無い軸は DEFAULT_SCORE で埋め、reasons はスコアに
    # 付いていた reason 文字列を集めたもの。最後に total_score の降順でソートして返す。
    raise NotImplementedError
