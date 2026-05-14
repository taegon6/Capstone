#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/python"
python mock_pose_demo.py
pytest
echo "Run MATLAB demos manually from MATLAB: addpath(genpath('matlab')); run('matlab/examples/run_offline_csi_demo.m')"
