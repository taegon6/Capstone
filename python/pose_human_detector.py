from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Tuple

from utils import Landmark, coerce_landmarks, mock_landmarks, utc_timestamp


@dataclass
class HumanDetectionResult:
    human: bool
    num_valid_keypoints: int
    avg_confidence: float
    timestamp: str

    def to_dict(self) -> Dict[str, Any]:
        return {
            "human": self.human,
            "num_valid_keypoints": self.num_valid_keypoints,
            "avg_confidence": self.avg_confidence,
            "timestamp": self.timestamp,
        }


def evaluate_human_from_landmarks(
    landmarks: List[Any],
    min_valid_keypoints: int = 8,
    min_avg_confidence: float = 0.5,
) -> HumanDetectionResult:
    parsed = coerce_landmarks(landmarks)
    valid = [lm for lm in parsed if lm.visibility >= min_avg_confidence]
    avg = sum(lm.visibility for lm in parsed) / len(parsed) if parsed else 0.0
    return HumanDetectionResult(
        human=len(valid) >= min_valid_keypoints and avg >= min_avg_confidence,
        num_valid_keypoints=len(valid),
        avg_confidence=avg,
        timestamp=utc_timestamp(),
    )


class PoseHumanDetector:
    def __init__(
        self,
        min_valid_keypoints: int = 8,
        min_avg_confidence: float = 0.5,
        mock_mode: bool = False,
    ) -> None:
        self.min_valid_keypoints = min_valid_keypoints
        self.min_avg_confidence = min_avg_confidence
        self.mock_mode = mock_mode
        self._mp_pose = None
        self._pose = None
        self._last_pose_landmarks = None

        if not mock_mode:
            try:
                import mediapipe as mp

                self._mp_pose = mp.solutions.pose
                self._pose = self._mp_pose.Pose(
                    static_image_mode=False,
                    model_complexity=1,
                    enable_segmentation=False,
                    min_detection_confidence=0.5,
                    min_tracking_confidence=0.5,
                )
            except Exception:
                self.mock_mode = True

    def detect_landmarks(self, frame: Optional[Any] = None) -> Tuple[List[Landmark], HumanDetectionResult]:
        self._last_pose_landmarks = None
        if self.mock_mode or frame is None:
            landmarks = mock_landmarks("standing")
            return landmarks, evaluate_human_from_landmarks(
                landmarks, self.min_valid_keypoints, self.min_avg_confidence
            )

        import cv2

        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self._pose.process(rgb)
        if not results.pose_landmarks:
            detection = evaluate_human_from_landmarks([], self.min_valid_keypoints, self.min_avg_confidence)
            return [], detection

        self._last_pose_landmarks = results.pose_landmarks
        landmarks = coerce_landmarks(results.pose_landmarks.landmark)
        detection = evaluate_human_from_landmarks(
            landmarks, self.min_valid_keypoints, self.min_avg_confidence
        )
        return landmarks, detection

    def draw(self, frame: Any, landmarks: List[Landmark]) -> Any:
        if self.mock_mode or self._mp_pose is None or self._last_pose_landmarks is None:
            return frame
        try:
            import mediapipe as mp

            drawing = mp.solutions.drawing_utils
            styles = mp.solutions.drawing_styles
            drawing.draw_landmarks(
                frame,
                self._last_pose_landmarks,
                self._mp_pose.POSE_CONNECTIONS,
                landmark_drawing_spec=styles.get_default_pose_landmarks_style(),
            )
            return frame
        except Exception:
            return frame
