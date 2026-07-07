"""location specialist: 座席の「場所」(section/position)がユーザーの希望とどれだけ合うかだけを評価する。
ツールは持たない。最終的なランキングはPython側(shared/scoring.py)が行う。"""

from google.adk import Agent

from agents._common import to_a2a_app
from agents.shared.models import AxisScoreList

root_agent = Agent(
    name="location_agent",
    model="gemini-flash-latest",
    description="座席の場所(前方/中央/後方、通路側/窓側/中央)が希望とどれだけ合うかを評価する。",
    instruction=(
        "ユーザーメッセージにはJSON形式で preference (preferred_section, preferred_position) と"
        " candidates (seat_id, section, position, price, tags) が渡されます。"
        "値段(price)やタグ(tags)は無視し、各候補のsectionとpositionが希望とどれだけ合うかだけを"
        "1〜10点で採点してください。希望が指定されていない項目は中立的に扱ってください。"
        "candidatesに含まれる座席は全件、必ず1件ずつ評価し、reasonは日本語で簡潔に書いてください。"
    ),
    output_schema=AxisScoreList,
    mode="single_turn",
)

app = to_a2a_app(root_agent, default_port=8102)
