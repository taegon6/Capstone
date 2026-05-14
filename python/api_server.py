from __future__ import annotations

from typing import Any, Dict

from fastapi import FastAPI
from pydantic import BaseModel, Field

from utils import utc_timestamp


class CsiResult(BaseModel):
    presence: bool = False
    motion: bool = False
    activity: str = "unknown"
    confidence: float = 0.0
    timestamp: str = Field(default_factory=utc_timestamp)


class PoseResult(BaseModel):
    human: bool = False
    posture: str = "unknown"
    avg_confidence: float = 0.0
    num_valid_keypoints: int = 0
    timestamp: str = Field(default_factory=utc_timestamp)


app = FastAPI(title="CSI Pose Capstone API")

STATE: Dict[str, Any] = {
    "csi": CsiResult().dict(),
    "pose": PoseResult().dict(),
    "updated_at": utc_timestamp(),
}


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok", "timestamp": utc_timestamp()}


@app.get("/status")
def status() -> Dict[str, Any]:
    return STATE


@app.post("/csi_result")
def post_csi_result(result: CsiResult) -> Dict[str, Any]:
    STATE["csi"] = result.dict()
    STATE["updated_at"] = utc_timestamp()
    return {"ok": True, "state": STATE}


@app.post("/pose_result")
def post_pose_result(result: PoseResult) -> Dict[str, Any]:
    STATE["pose"] = result.dict()
    STATE["updated_at"] = utc_timestamp()
    return {"ok": True, "state": STATE}


# Future API/LLM integration belongs here, with API keys read from environment
# variables instead of being hard-coded.
