"""preference_parser: 自然文の要望をSeatPreferenceに構造化するローカルLLM。
構造化した後の正規化(語彙のクランプ等)はPython(shared/preference.py)が担う。"""

from google.adk import Agent, Context

from agents.shared.models import SeatPreference
from agents.shared.preference import normalize_preference

preference_parser_agent = Agent(
    name="preference_parser",
    model="gemini-flash-latest",
    description="ユーザーの自然文の座席要望をSeatPreferenceへ構造化する。",
    instruction=(
        "ユーザーの座席予約に関する要望を読み取り、SeatPreference形式で出力してください。"
        "preferred_sectionはfront/middle/backのいずれか、preferred_positionはaisle/window/centerの"
        "いずれかを、要望から明確に読み取れる場合だけ設定してください。分からなければnullにしてください。"
        "max_priceは要望されている上限予算を円で(明示されていなければnull)。"
        "desired_effectsはquiet/view/power/spacious/aisle-easyの中から当てはまるものだけを選んでください。"
        "free_textには元のユーザー発言をそのまま入れてください。"
    ),
    output_schema=SeatPreference,
    mode="single_turn",
)


def normalize_preference_node(ctx: Context, node_input) -> SeatPreference:
    preference = normalize_preference(node_input)
    ctx.state["seat_preference"] = preference.model_dump()
    return preference
