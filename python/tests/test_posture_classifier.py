from posture_classifier import PostureClassifier
from utils import mock_landmarks


def test_standing_rule():
    result = PostureClassifier().classify(mock_landmarks("standing"))
    assert result.posture == "standing"


def test_sitting_rule():
    result = PostureClassifier().classify(mock_landmarks("sitting"))
    assert result.posture == "sitting"


def test_lying_rule():
    result = PostureClassifier().classify(mock_landmarks("lying"))
    assert result.posture == "lying"


def test_possible_fall_rule():
    result = PostureClassifier().classify(mock_landmarks("possible_fall"), previous_center=(0.3, 0.3))
    assert result.posture == "possible_fall"

