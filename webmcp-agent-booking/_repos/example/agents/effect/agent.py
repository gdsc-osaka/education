"""effect specialist: 座席のタグ(quiet/view/power/spacious/aisle-easy)が
ユーザーの希望する効果とどれだけ合うかだけを評価する。
ツールは持たない。最終的なランキングはPython側(shared/scoring.py)が行う。"""

from google.adk import Agent

from agents._common import to_a2a_app
from agents.shared.models import AxisScoreList

root_agent = Agent(
    name="effect_agent",
    model="gemini-flash-latest",
    description="座席のタグ(quiet/view/power/spacious/aisle-easy)が希望する効果とどれだけ合うかを評価する。",
    instruction=(
        "ユーザーメッセージにはJSON形式で preference (desired_effects) と"
        " candidates (seat_id, section, position, price, tags) が渡されます。"
        "場所(section/position)や値段(price)は無視し、各候補のtagsがdesired_effectsと"
        "どれだけ重なっているかだけを1〜10点で採点してください。desired_effectsが空の場合は"
        "中立的に5点前後で構いません。"
        "candidatesに含まれる座席は全件、必ず1件ずつ評価し、reasonは日本語で簡潔に書いてください。"
    ),
    output_schema=AxisScoreList,
    mode="single_turn",
)

app = to_a2a_app(root_agent, default_port=8104)
