from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Dict, Iterable, List, Optional


@dataclass
class Landmark:
    x: float
    y: float
    z: float = 0.0
    visibility: float = 1.0


def utc_timestamp() -> str:
    return datetime.now(timezone.utc).isoformat()


def landmark_to_dict(landmark: Landmark) -> Dict[str, float]:
    return {
        "x": float(landmark.x),
        "y": float(landmark.y),
        "z": float(landmark.z),
        "visibility": float(landmark.visibility),
    }


def coerce_landmark(item: Any) -> Landmark:
    if isinstance(item, Landmark):
        return item
    if isinstance(item, dict):
        return Landmark(
            x=float(item.get("x", 0.0)),
            y=float(item.get("y", 0.0)),
            z=float(item.get("z", 0.0)),
            visibility=float(item.get("visibility", item.get("confidence", 0.0))),
        )
    return Landmark(
        x=float(getattr(item, "x", 0.0)),
        y=float(getattr(item, "y", 0.0)),
        z=float(getattr(item, "z", 0.0)),
        visibility=float(getattr(item, "visibility", 0.0)),
    )


def coerce_landmarks(items: Optional[Iterable[Any]]) -> List[Landmark]:
    if not items:
        return []
    return [coerce_landmark(item) for item in items]


def mock_landmarks(posture: str = "standing", confidence: float = 0.9) -> List[Landmark]:
    points = [Landmark(0.5, 0.5, visibility=confidence) for _ in range(33)]

    def set_point(idx: int, x: float, y: float) -> None:
        points[idx] = Landmark(x, y, 0.0, confidence)

    if posture == "standing":
        coords = {
            11: (0.42, 0.25), 12: (0.58, 0.25),
            23: (0.44, 0.52), 24: (0.56, 0.52),
            25: (0.45, 0.72), 26: (0.55, 0.72),
            27: (0.45, 0.92), 28: (0.55, 0.92),
        }
    elif posture == "sitting":
        coords = {
            11: (0.42, 0.30), 12: (0.58, 0.30),
            23: (0.43, 0.58), 24: (0.57, 0.58),
            25: (0.32, 0.72), 26: (0.68, 0.72),
            27: (0.30, 0.78), 28: (0.70, 0.78),
        }
    elif posture == "lying":
        coords = {
            11: (0.22, 0.48), 12: (0.34, 0.50),
            23: (0.55, 0.52), 24: (0.66, 0.53),
            25: (0.76, 0.54), 26: (0.84, 0.55),
            27: (0.90, 0.56), 28: (0.96, 0.57),
        }
    elif posture == "possible_fall":
        coords = {
            11: (0.25, 0.62), 12: (0.36, 0.64),
            23: (0.58, 0.66), 24: (0.70, 0.67),
            25: (0.80, 0.68), 26: (0.90, 0.70),
            27: (0.92, 0.74), 28: (0.98, 0.76),
        }
    else:
        coords = {}

    for idx, (x, y) in coords.items():
        set_point(idx, x, y)
    return points

