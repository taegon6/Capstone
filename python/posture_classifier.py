from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Tuple

from utils import coerce_landmarks


@dataclass
class PostureResult:
    posture: str
    confidence: float
    details: Dict[str, float]

    def to_dict(self) -> Dict[str, Any]:
        return {
            "posture": self.posture,
            "confidence": self.confidence,
            "details": self.details,
        }


class PostureClassifier:
    SHOULDER = (11, 12)
    HIP = (23, 24)
    KNEE = (25, 26)
    ANKLE = (27, 28)

    def classify(self, landmarks: List[Any], previous_center: Optional[Tuple[float, float]] = None) -> PostureResult:
        points = coerce_landmarks(landmarks)
        visible = [p for p in points if p.visibility >= 0.4]
        if len(visible) < 8:
            return PostureResult("unknown", 0.0, {"visible": float(len(visible))})

        xs = [p.x for p in visible]
        ys = [p.y for p in visible]
        width = max(xs) - min(xs)
        height = max(ys) - min(ys)
        aspect = height / max(width, 1e-6)
        center = (sum(xs) / len(xs), sum(ys) / len(ys))
        center_shift = 0.0
        if previous_center is not None:
            center_shift = ((center[0] - previous_center[0]) ** 2 + (center[1] - previous_center[1]) ** 2) ** 0.5

        shoulder_y = self._mean_y(points, self.SHOULDER)
        hip_y = self._mean_y(points, self.HIP)
        knee_y = self._mean_y(points, self.KNEE)
        ankle_y = self._mean_y(points, self.ANKLE)
        torso = hip_y - shoulder_y
        leg = ankle_y - hip_y
        knee_bend = abs(knee_y - hip_y)

        details = {
            "aspect": aspect,
            "center_x": center[0],
            "center_y": center[1],
            "center_shift": center_shift,
            "torso": torso,
            "leg": leg,
            "knee_bend": knee_bend,
            "visible": float(len(visible)),
        }

        if aspect < 0.75:
            if center_shift > 0.12 or center[1] > 0.58:
                return PostureResult("possible_fall", 0.75, details)
            return PostureResult("lying", 0.8, details)

        if aspect > 1.25 and leg > 0.30 and torso > 0.15:
            return PostureResult("standing", 0.8, details)

        if knee_bend < 0.22 or leg < 0.30:
            return PostureResult("sitting", 0.7, details)

        return PostureResult("unknown", 0.35, details)

    @staticmethod
    def _mean_y(points: List[Any], indices: Tuple[int, int]) -> float:
        vals = []
        for idx in indices:
            if idx < len(points):
                vals.append(points[idx].y)
        return sum(vals) / len(vals) if vals else 0.0

