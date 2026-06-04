from api_server import app_config, health, post_csi_result, post_demo_status, post_pose_result, status
from api_server import CsiResult, PoseResult


def test_health_reports_ok():
    result = health()
    assert result["status"] == "ok"
    assert "timestamp" in result


def test_app_config_lists_android_endpoints():
    result = app_config()
    assert result["endpoints"]["status"] == "/status"
    assert result["endpoints"]["post_demo_status"] == "/demo/mock_status"


def test_status_updates_from_posts():
    post_csi_result(CsiResult(presence=True, motion=False, activity="standing", confidence=0.7))
    post_pose_result(PoseResult(human=True, posture="sitting", avg_confidence=0.8, num_valid_keypoints=20))

    result = status()
    assert result["csi"]["presence"] is True
    assert result["csi"]["activity"] == "standing"
    assert result["pose"]["human"] is True
    assert result["pose"]["posture"] == "sitting"


def test_demo_status_seeds_mock_data():
    result = post_demo_status()
    assert result["ok"] is True
    assert result["state"]["csi"]["activity"] == "walking"
    assert result["state"]["pose"]["posture"] == "standing"
