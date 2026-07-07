"""ユーザーの希望(SeatPreference)をPythonで正規化する。LLMの自由記述に頼らない。"""

from __future__ import annotations

from .models import SeatPreference

SECTIONS = ("front", "middle", "back")
POSITIONS = ("aisle", "window", "center")
EFFECT_TAGS = ("quiet", "view", "power", "spacious", "aisle-easy")


def normalize_preference(value: SeatPreference | dict | str) -> SeatPreference:
    if isinstance(value, SeatPreference):
        preference = value
    elif isinstance(value, dict):
        preference = SeatPreference.model_validate(value)
    else:
        preference = SeatPreference(free_text=str(value))

    section = preference.preferred_section if preference.preferred_section in SECTIONS else None
    position = preference.preferred_position if preference.preferred_position in POSITIONS else None
    effects = [tag for tag in dict.fromkeys(preference.desired_effects) if tag in EFFECT_TAGS]

    max_price = preference.max_price
    if max_price is not None and max_price <= 0:
        max_price = None

    return preference.model_copy(
        update={
            "preferred_section": section,
            "preferred_position": position,
            "desired_effects": effects,
            "max_price": max_price,
        }
    )
