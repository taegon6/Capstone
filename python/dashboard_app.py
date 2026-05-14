from __future__ import annotations

import json
import time
import urllib.request


def fetch_status(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=2) as response:
        return json.loads(response.read().decode("utf-8"))


def render(state: dict) -> None:
    csi = state.get("csi", {})
    pose = state.get("pose", {})
    print("\033c", end="")
    print("CSI + Camera Integrated Dashboard")
    print("=" * 40)
    print(f"Updated          : {state.get('updated_at', '-')}")
    print(f"CSI presence     : {csi.get('presence')}")
    print(f"CSI motion       : {csi.get('motion')}")
    print(f"CSI activity     : {csi.get('activity')}")
    print(f"Camera human     : {pose.get('human')}")
    print(f"Camera posture   : {pose.get('posture')}")
    print(f"Camera confidence: {pose.get('avg_confidence')}")


def main() -> None:
    url = "http://127.0.0.1:8000/status"
    print("Polling API server. Press Ctrl+C to stop.")
    while True:
        try:
            render(fetch_status(url))
        except Exception as exc:
            print(f"Waiting for API server at {url}: {exc}")
        time.sleep(1)


if __name__ == "__main__":
    main()

