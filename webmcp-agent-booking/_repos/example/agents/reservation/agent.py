"""reservation specialist: 宣言型WebMCPフォームtool(reserve_seat)で実際に1席予約し、
命令型ツール(list_reservations)で結果を確認する。成功/失敗の判定はしない(Pythonが判定する)。"""

from google.adk import Agent

from agents._common import to_a2a_app
from agents.shared.models import ReservationAttemptResult
from agents.webmcp_tools import build_reservation_toolset

root_agent = Agent(
    name="reservation_agent",
    model="gemini-flash-latest",
    description="reserve_seatフォームtoolで1席予約し、list_reservationsで結果を確認する。",
    instruction=(
        "ユーザーメッセージにはJSON形式で seat_id, display_name, note が渡されます。"
        "まず reserve_seat ツールを、seatId=seat_id, displayName=display_name, note=note で"
        "呼び出してください。次に list_reservations ツールを呼び出し、その時点の予約一覧をすべて取得してください。"
        "成功したか失敗したかを自分で判断する必要はありません。seat_id と、"
        "list_reservationsで取得した予約一覧(reservations_snapshot)をそのまま出力してください。"
    ),
    tools=[build_reservation_toolset()],
    output_schema=ReservationAttemptResult,
    mode="single_turn",
)

app = to_a2a_app(root_agent, default_port=8105)
