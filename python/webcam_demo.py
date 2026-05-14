from __future__ import annotations

from pose_human_detector import PoseHumanDetector
from posture_classifier import PostureClassifier


def main() -> None:
    try:
        import cv2
    except Exception as exc:
        print(f"OpenCV import failed. Run mock_pose_demo.py instead. Error: {exc}")
        return

    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Camera not found. Falling back to mock_pose_demo.py logic.")
        from mock_pose_demo import main as mock_main

        mock_main()
        return

    detector = PoseHumanDetector()
    classifier = PostureClassifier()
    previous_center = None

    while True:
        ok, frame = cap.read()
        if not ok:
            break
        landmarks, human = detector.detect_landmarks(frame)
        posture = classifier.classify(landmarks, previous_center=previous_center)
        previous_center = (
            posture.details.get("center_x", 0.0),
            posture.details.get("center_y", 0.0),
        )
        label = (
            f"human={human.human} posture={posture.posture} "
            f"conf={human.avg_confidence:.2f}"
        )
        cv2.putText(frame, label, (20, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.imshow("Pose Human Detector", frame)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()

