"""予約の成否判定とメッセージ生成。判定はPythonのデータ照合のみで行い、
LLMには「Pythonが確定した結果を自然文で説明させる」役割しか持たせない（最重要方針）。"""

from __future__ import annotations

MAX_ATTEMPTS = 3


def confirm_reservation(seat_id: str, reservations_snapshot: list[dict]) -> bool:
    """reservation specialistがreserve_seat実行後にlist_reservationsで取得したスナップショットから、
    実際にその座席が予約済みリストに入っているかをPythonで確認する。"""
    # TODO: reservations_snapshot の各要素の "seatId" が seat_id と一致するものが
    # 1件でもあれば True を返す。
    raise NotImplementedError


def build_success_message(seat_id: str, reasons: list[str]) -> str:
    # TODO: "座席 {seat_id} の予約が完了しました。" を基本に、reasons があれば
    # 選定理由として付け加えた文字列を返す。
    raise NotImplementedError


def build_failure_message(attempted_seat_ids: list[str]) -> str:
    # TODO: attempted_seat_ids が空なら「空席が見つからなかった」旨、
    # 非空なら試した座席IDを列挙して「いずれも予約できなかった」旨の文字列を返す。
    raise NotImplementedError
