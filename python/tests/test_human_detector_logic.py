from pose_human_detector import evaluate_human_from_landmarks
from utils import mock_landmarks


def test_human_true_when_enough_keypoints_and_confidence():
    result = evaluate_human_from_landmarks(mock_landmarks("standing", confidence=0.9))
    assert result.human is True
    assert result.num_valid_keypoints >= 8
    assert result.avg_confidence >= 0.5


def test_human_false_when_confidence_low():
    result = evaluate_human_from_landmarks(mock_landmarks("standing", confidence=0.2))
    assert result.human is False


def test_human_false_when_no_landmarks():
    result = evaluate_human_from_landmarks([])
    assert result.human is False
    assert result.num_valid_keypoints == 0
