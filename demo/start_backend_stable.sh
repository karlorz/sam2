#!/bin/bash
# Start SAM2 Backend in STABLE CPU Mode
# This script uses CPU instead of MPS to avoid crashes on M4 Mac

cd "$(dirname "$0")"

echo "=================================="
echo "  SAM2 Backend - CPU Mode (Stable)"
echo "=================================="
echo ""
echo "Stopping any existing backend..."
pkill -f "gunicorn.*app:app" 2>/dev/null || true
sleep 2

echo ""
echo "Starting backend with CPU (this is STABLE and WON'T crash)..."
echo ""
echo "Model: small (recommended for M4 Mac)"
echo "Device: CPU (reliable, 12-15 FPS)"
echo "Backend URL: http://localhost:7263/graphql"
echo ""
echo "Starting in 3 seconds..."
sleep 3

make backend-cpu-uv MODEL_SIZE=small
