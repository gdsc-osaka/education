"""seat_finder specialist: 命令型WebMCPツール(list_available_seats, get_seat_detail)だけを使い、
現在の空席状況を取得してSeatCandidatesとして返す。ランキングや予約はしない。"""

from google.adk import Agent

from agents._common import to_a2a_app
from agents.shared.models import SeatCandidates
from agents.webmcp_tools import build_seat_finder_toolset

root_agent = Agent(
    name="seat_finder_agent",
    model="gemini-flash-latest",
    description="WebMCPの命令型ツールで現在の空席一覧を取得する。",
    instruction=(
        "list_available_seats ツールを呼び出し、現在空いている座席を取得してください。"
        "必要であれば get_seat_detail で個々の座席の詳細も確認できます。"
        "取得した座席それぞれについて、seat_id, section, position, price, tags, status を"
        "そのまま SeatCandidates 形式で出力してください。並び替えや評価は行わないでください。"
    ),
    tools=[build_seat_finder_toolset()],
    output_schema=SeatCandidates,
    mode="single_turn",
)

app = to_a2a_app(root_agent, default_port=8101)
