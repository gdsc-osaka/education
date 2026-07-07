"""ユーザーの希望(SeatPreference)をPythonで正規化する。LLMの自由記述に頼らない。"""

from __future__ import annotations

from .models import SeatPreference

SECTIONS = ("front", "middle", "back")
POSITIONS = ("aisle", "window", "center")
EFFECT_TAGS = ("quiet", "view", "power", "spacious", "aisle-easy")


def normalize_preference(value: SeatPreference | dict | str) -> SeatPreference:
    # TODO: value が SeatPreference / dict / str のいずれで来ても SeatPreference に揃える。
    # そのうえで、preferred_section は SECTIONS に、preferred_position は POSITIONS に、
    # desired_effects は EFFECT_TAGS に含まれるものだけへクランプ（重複除去）し、
    # max_price が 0 以下なら None にして返す。
    raise NotImplementedError
