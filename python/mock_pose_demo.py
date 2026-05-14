from __future__ import annotations

from pose_human_detector import evaluate_human_from_landmarks
from posture_classifier import PostureClassifier
from utils import mock_landmarks


def main() -> None:
    classifier = PostureClassifier()
    for posture in ["standing", "sitting", "lying", "possible_fall"]:
        landmarks = mock_landmarks(posture, confidence=0.9)
        human = evaluate_human_from_landmarks(landmarks)
        previous_center = (0.3, 0.3) if posture == "possible_fall" else None
        result = classifier.classify(landmarks, previous_center=previous_center)
        print(
            f"mock={posture:13s} human={human.human} "
            f"valid={human.num_valid_keypoints:02d} avg_conf={human.avg_confidence:.2f} "
            f"posture={result.posture} confidence={result.confidence:.2f}"
        )


if __name__ == "__main__":
    main()
