#!/usr/bin/env bash
# ===========================================================================
# build_trt_jetson.sh — Build SPNet TensorRT engines on Jetson (aarch64)
# ===========================================================================
# On Jetson, TensorRT is installed via JetPack apt (system-wide), so trtexec
# lives at /usr/src/tensorrt/bin/trtexec and libs are in /usr/lib/aarch64-linux-gnu.
#
# Engines are architecture-specific: an engine built on x86 will NOT load on
# Jetson and vice-versa.  Run this script ON the Jetson device.
# ===========================================================================
set -e

# --- Locate trtexec --------------------------------------------------------
TRT_BIN=""
for candidate in \
  /usr/src/tensorrt/bin/trtexec \
  /usr/local/TensorRT/bin/trtexec \
  "$TENSORRT_ROOT/bin/trtexec"; do
  if [ -x "$candidate" ]; then
    TRT_BIN="$candidate"
    break
  fi
done
if [ -z "$TRT_BIN" ]; then
  echo "ERROR: trtexec not found. Install with: sudo apt install tensorrt"
  exit 1
fi
echo ">>> Using trtexec: $TRT_BIN"

# --- TensorRT lib path (aarch64) -------------------------------------------
if [ -n "$TENSORRT_ROOT" ] && [ -d "$TENSORRT_ROOT/targets/aarch64-linux-gnu/lib" ]; then
  TRT_LIB="$TENSORRT_ROOT/targets/aarch64-linux-gnu/lib"
else
  TRT_LIB="/usr/lib/aarch64-linux-gnu"
fi
echo ">>> TensorRT lib: $TRT_LIB"

echo ">>> Deactivating conda env (if any)"
conda deactivate 2>/dev/null || true

echo ">>> Setting TensorRT LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$TRT_LIB"

# --- Determine script directory --------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --- Build engines ---------------------------------------------------------
# FP16 is used on Jetson for speed and memory efficiency.
# --workspaceSize is reduced for Jetson's shared memory.

echo ">>> Building TensorRT engine: 512x640"
"$TRT_BIN" \
  --onnx=spnet_512_640.onnx \
  --saveEngine=spnet_512_640.engine \
  --fp16 \
  --workspaceSize=512 \
  --optShapes=rgb:1x3x512x640,depth:1x1x512x640,mask:1x1x512x640

echo ">>> Building TensorRT engine: 480x640"
"$TRT_BIN" \
  --onnx=spnet_480_640.onnx \
  --saveEngine=spnet_480_640.engine \
  --fp16 \
  --workspaceSize=512 \
  --optShapes=rgb:1x3x480x640,depth:1x1x480x640,mask:1x1x480x640

echo ">>> TensorRT engine build finished (Jetson aarch64)."
echo ">>> Engines: spnet_512_640.engine, spnet_480_640.engine"
