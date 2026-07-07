"""Agent間で受け渡す構造化データ（Pydanticモデル）。"""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


class SeatPreference(BaseModel):
    preferred_section: str | None = Field(default=None, description="front/middle/back のいずれか")
    preferred_position: str | None = Field(default=None, description="aisle/window/center のいずれか")
    max_price: int | None = Field(default=None, description="希望する上限予算（円）")
    desired_effects: list[str] = Field(default_factory=list, description="quiet/view/power/spacious等の希望タグ")
    free_text: str = Field(default="", description="ユーザーの元の発言")


class SeatCandidate(BaseModel):
    seat_id: str
    section: str
    position: str
    price: int
    tags: list[str] = Field(default_factory=list)
    status: str = "available"


class SeatCandidates(BaseModel):
    candidates: list[SeatCandidate] = Field(default_factory=list)


class AxisScore(BaseModel):
    seat_id: str
    score: int = Field(ge=1, le=10)
    reason: str = ""


class AxisScoreList(BaseModel):
    """1軸specialistの出力。axisラベル自体はPython側(coordinator)が付与するため含まない。"""

    scores: list[AxisScore] = Field(default_factory=list)


class EvaluationReport(BaseModel):
    axis: Literal["location", "price", "effect"]
    scores: list[AxisScore] = Field(default_factory=list)


class RankedSeat(BaseModel):
    seat_id: str
    total_score: float
    axis_scores: dict[str, int] = Field(default_factory=dict)
    reasons: list[str] = Field(default_factory=list)


class ReservationAttemptResult(BaseModel):
    """reservation specialistの生の出力。成功/失敗の判定はしない(Pythonが判定する)。"""

    seat_id: str
    reservations_snapshot: list[dict] = Field(default_factory=list)


class ReservationOutcome(BaseModel):
    status: Literal["success", "failed"]
    seat_id: str | None = None
    message: str
    attempts: list[str] = Field(default_factory=list)
