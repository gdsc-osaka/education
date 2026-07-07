"""座席予約コーディネーター。手順・分岐・ランキング・リトライは全てこのWorkflowの
edges(Pythonコード)で明示的に制御する。Workflow自体にはinstructionを持たせない。"""

from typing import Any

from google.adk import Context, Workflow

from agents._common import to_a2a_app
from agents.coordinator.candidates import coerce_candidates, seat_finder_remote
from agents.coordinator.evaluation import evaluate_axes
from agents.coordinator.explain import build_explainer_input, explainer_agent
from agents.coordinator.parse import normalize_preference_node, preference_parser_agent
from agents.coordinator.reservation_flow import reserve_with_retry
from agents.shared.models import EvaluationReport, SeatCandidate
from agents.shared.scoring import score_and_rank


def capture_user_query(ctx: Context, _: Any = None) -> str:
    content = ctx.user_content
    if content and content.parts:
        return "\n".join(part.text for part in content.parts if part.text)
    return ""


def rank_candidates(ctx: Context, reports: list[EvaluationReport]):
    candidates = [SeatCandidate.model_validate(c) for c in ctx.state["seat_candidates"]]
    ranked = score_and_rank(candidates, reports)
    ctx.state["ranked_seats"] = [r.model_dump() for r in ranked]
    return ranked


root_agent = Workflow(
    name="seat_booking_coordinator",
    description=(
        "WebMCPで座席状況を取得し、場所/値段/効果の3軸で評価してPythonでランキングし、"
        "宣言型toolで実際に予約するコーディネーター。"
    ),
    edges=[
        (
            "START",
            capture_user_query,
            preference_parser_agent,
            normalize_preference_node,
            seat_finder_remote,
            coerce_candidates,
            evaluate_axes,
            rank_candidates,
            reserve_with_retry,
            build_explainer_input,
            explainer_agent,
        ),
    ],
)

app = to_a2a_app(root_agent, default_port=8100)
