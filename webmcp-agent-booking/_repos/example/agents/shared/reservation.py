"""予約の成否判定とメッセージ生成。判定はPythonのデータ照合のみで行い、
LLMには「Pythonが確定した結果を自然文で説明させる」役割しか持たせない（最重要方針）。"""

from __future__ import annotations

MAX_ATTEMPTS = 3


def confirm_reservation(seat_id: str, reservations_snapshot: list[dict]) -> bool:
    """reservation specialistがreserve_seat実行後にlist_reservationsで取得したスナップショットから、
    実際にその座席が予約済みリストに入っているかをPythonで確認する。"""
    return any(reservation.get("seatId") == seat_id for reservation in reservations_snapshot)


def build_success_message(seat_id: str, reasons: list[str]) -> str:
    message = f"座席 {seat_id} の予約が完了しました。"
    if reasons:
        message += " 選定理由: " + " / ".join(reasons)
    return message


def build_failure_message(attempted_seat_ids: list[str]) -> str:
    if not attempted_seat_ids:
        return "条件に合う空席が見つからなかったため、予約できませんでした。"
    tried = "、".join(attempted_seat_ids)
    return f"候補の座席（{tried}）はいずれも予約できませんでした。時間をおいて再度お試しください。"
