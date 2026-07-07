"""場所/値段/効果の3specialistをasyncio.gatherで並列に呼び出す。
各specialistは1軸のスコアだけを提案し、axisラベルの付与とレポートの組み立てはPythonが行う。"""

import asyncio
import json

from google.adk import Context
from google.adk.agents.remote_a2a_agent import RemoteA2aAgent

from agents._common import remote_agent_card_url
from agents.shared.models import (
    AxisScore,
    AxisScoreList,
    EvaluationReport,
    SeatCandidate,
    SeatPreference,
)

location_remote = RemoteA2aAgent(
    name="location_remote",
    agent_card=remote_agent_card_url("LOCATION_A2A_URL", "http://localhost:8102"),
    description="座席の場所(場所/位置)の希望適合度を評価するspecialist。",
    output_schema=AxisScoreList,
    use_legacy=False,
)

price_remote = RemoteA2aAgent(
    name="price_remote",
    agent_card=remote_agent_card_url("PRICE_A2A_URL", "http://localhost:8103"),
    description="座席の値段の希望適合度を評価するspecialist。",
    output_schema=AxisScoreList,
    use_legacy=False,
)

effect_remote = RemoteA2aAgent(
    name="effect_remote",
    agent_card=remote_agent_card_url("EFFECT_A2A_URL", "http://localhost:8104"),
    description="座席の効果(タグ)の希望適合度を評価するspecialist。",
    output_schema=AxisScoreList,
    use_legacy=False,
)


def _build_axis_input(preference: SeatPreference, candidates: list[SeatCandidate]) -> str:
    payload = {
        "preference": preference.model_dump(),
        "candidates": [c.model_dump() for c in candidates],
    }
    return json.dumps(payload, ensure_ascii=False)


def _coerce_scores(value) -> list[AxisScore]:
    try:
        if isinstance(value, AxisScoreList):
            return value.scores
        if isinstance(value, dict):
            return AxisScoreList.model_validate(value).scores
        if isinstance(value, str):
            return AxisScoreList.model_validate(json.loads(value)).scores
    except (json.JSONDecodeError, ValueError):
        pass
    return []


async def evaluate_axes(ctx: Context, candidates: list[SeatCandidate]) -> list[EvaluationReport]:
    preference = SeatPreference.model_validate(ctx.state["seat_preference"])
    axis_input = _build_axis_input(preference, candidates)

    location_result, price_result, effect_result = await asyncio.gather(
        ctx.run_node(location_remote, axis_input),
        ctx.run_node(price_remote, axis_input),
        ctx.run_node(effect_remote, axis_input),
    )

    reports = [
        EvaluationReport(axis="location", scores=_coerce_scores(location_result)),
        EvaluationReport(axis="price", scores=_coerce_scores(price_result)),
        EvaluationReport(axis="effect", scores=_coerce_scores(effect_result)),
    ]
    ctx.state["evaluation_reports"] = [r.model_dump() for r in reports]
    return reports
