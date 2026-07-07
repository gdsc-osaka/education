"""seat_finder specialistをRemoteA2aAgentとして呼び出し、結果をSeatCandidateリストへ変換する。
LLM出力の揺れに備えて、パース失敗時は空リストへフォールバックする(Python側の安全網)。"""

import json

from google.adk import Context
from google.adk.agents.remote_a2a_agent import RemoteA2aAgent

from agents._common import remote_agent_card_url
from agents.shared.models import SeatCandidate, SeatCandidates

seat_finder_remote = RemoteA2aAgent(
    name="seat_finder_remote",
    agent_card=remote_agent_card_url("SEAT_FINDER_A2A_URL", "http://localhost:8101"),
    description="WebMCP命令型ツールで現在の空席一覧を取得するspecialist。",
    output_schema=SeatCandidates,
    use_legacy=False,
)


def coerce_candidates(ctx: Context, node_input) -> list[SeatCandidate]:
    candidates: list[SeatCandidate] = []
    try:
        if isinstance(node_input, SeatCandidates):
            candidates = node_input.candidates
        elif isinstance(node_input, dict):
            candidates = SeatCandidates.model_validate(node_input).candidates
        elif isinstance(node_input, str):
            candidates = SeatCandidates.model_validate(json.loads(node_input)).candidates
    except (json.JSONDecodeError, ValueError):
        candidates = []

    available = [c for c in candidates if c.status == "available"]
    ctx.state["seat_candidates"] = [c.model_dump() for c in available]
    return available
