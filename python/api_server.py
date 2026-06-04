from __future__ import annotations

import os
from typing import Any, Dict

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
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


def model_to_dict(model: BaseModel) -> Dict[str, Any]:
    if hasattr(model, "model_dump"):
        return model.model_dump()
    return model.dict()


def parse_cors_origins() -> list[str]:
    raw_origins = os.environ.get("API_CORS_ORIGINS", "*")
    return [origin.strip() for origin in raw_origins.split(",") if origin.strip()]


app.add_middleware(
    CORSMiddleware,
    allow_origins=parse_cors_origins(),
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

STATE: Dict[str, Any] = {
    "csi": model_to_dict(CsiResult()),
    "pose": model_to_dict(PoseResult()),
    "updated_at": utc_timestamp(),
}


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok", "timestamp": utc_timestamp()}


@app.get("/app_config")
def app_config() -> Dict[str, Any]:
    return {
        "name": "CSI Pose Capstone",
        "version": "0.1.0",
        "endpoints": {
            "health": "/health",
            "status": "/status",
            "post_csi_result": "/csi_result",
            "post_pose_result": "/pose_result",
            "post_demo_status": "/demo/mock_status",
        },
        "status_schema": {
            "csi": list(CsiResult.model_fields.keys())
            if hasattr(CsiResult, "model_fields")
            else list(CsiResult.__fields__.keys()),
            "pose": list(PoseResult.model_fields.keys())
            if hasattr(PoseResult, "model_fields")
            else list(PoseResult.__fields__.keys()),
        },
    }


@app.get("/status")
def status() -> Dict[str, Any]:
    return STATE


@app.post("/csi_result")
def post_csi_result(result: CsiResult) -> Dict[str, Any]:
    STATE["csi"] = model_to_dict(result)
    STATE["updated_at"] = utc_timestamp()
    return {"ok": True, "state": STATE}


@app.post("/pose_result")
def post_pose_result(result: PoseResult) -> Dict[str, Any]:
    STATE["pose"] = model_to_dict(result)
    STATE["updated_at"] = utc_timestamp()
    return {"ok": True, "state": STATE}


@app.post("/demo/mock_status")
def post_demo_status() -> Dict[str, Any]:
    STATE["csi"] = model_to_dict(
        CsiResult(
            presence=True,
            motion=True,
            activity="walking",
            confidence=0.82,
        )
    )
    STATE["pose"] = model_to_dict(
        PoseResult(
            human=True,
            posture="standing",
            avg_confidence=0.91,
            num_valid_keypoints=27,
        )
    )
    STATE["updated_at"] = utc_timestamp()
    return {"ok": True, "state": STATE}


# Future API/LLM integration belongs here, with API keys read from environment
# variables instead of being hard-coded.


if __name__ == "__main__":
    import uvicorn

    host = os.environ.get("API_HOST", "0.0.0.0")
    port = int(os.environ.get("API_PORT", "8000"))
    uvicorn.run("api_server:app", host=host, port=port, reload=False)
