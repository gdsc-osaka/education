"""price specialist: 座席の値段がユーザーの予算とどれだけ合うかだけを評価する。
ツールは持たない。最終的なランキングはPython側(shared/scoring.py)が行う。"""

from google.adk import Agent

from agents._common import to_a2a_app
from agents.shared.models import AxisScoreList

root_agent = Agent(
    name="price_agent",
    model="gemini-flash-latest",
    description="座席の値段(price)が希望の予算(max_price)にどれだけ合うかを評価する。",
    instruction=(
        "ユーザーメッセージにはJSON形式で preference (max_price) と"
        " candidates (seat_id, section, position, price, tags) が渡されます。"
        "場所(section/position)やタグ(tags)は無視し、各候補のpriceがmax_priceに対してどれだけ"
        "適切かだけを1〜10点で採点してください。max_priceが指定されていない場合は、"
        "単純に安いほど高得点として構いません。予算を超えている候補は低い点数にしてください。"
        "candidatesに含まれる座席は全件、必ず1件ずつ評価し、reasonは日本語で簡潔に書いてください。"
    ),
    output_schema=AxisScoreList,
    mode="single_turn",
)

app = to_a2a_app(root_agent, default_port=8103)
