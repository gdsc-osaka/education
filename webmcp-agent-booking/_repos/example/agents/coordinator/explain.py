"""explainer: Python側が確定させた予約結果を自然な日本語に整形するだけのローカルLLM。
判断や事実の変更は行わない(最重要方針: 成功/失敗はPython helperが決める)。"""

import json

from google.adk import Agent, Context

from agents.shared.models import ReservationOutcome


def build_explainer_input(ctx: Context, outcome: ReservationOutcome) -> str:
    """次のLLMノードに渡す前に、必ずPython側でJSON文字列へ明示的に変換する。"""
    if isinstance(outcome, ReservationOutcome):
        payload = outcome.model_dump()
    elif isinstance(outcome, dict):
        payload = outcome
    else:
        payload = ctx.state.get("reservation_outcome", {})
    return json.dumps(payload, ensure_ascii=False)


explainer_agent = Agent(
    name="explainer_agent",
    model="gemini-flash-latest",
    description="Pythonが確定した予約結果を、参加者向けの自然な日本語メッセージに整形する。",
    instruction=(
        "ユーザーメッセージにはJSON形式で予約結果(status, seat_id, message, attempts)が渡されます。"
        "この内容を判断し直したり、書かれていない情報を付け加えたりせず、"
        "書かれている事実だけを使って、参加者への丁寧で簡潔な日本語の案内文に書き直してください。"
        "成功していないのに成功したように書かないでください。"
    ),
    mode="single_turn",
)
