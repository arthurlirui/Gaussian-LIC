#!/usr/bin/env bash
# ===========================================================================
# jetson_env.sh — Source this to set up the Jetson build/runtime environment
# ===========================================================================
# Usage:  source jetson_env.sh
# ===========================================================================

# CUDA (JetPack installs to /usr/local/cuda, symlinked to the real version)
export CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}"

# LibTorch (extracted by install_libtorch_jetson.sh)
export Torch_DIR="${HOME}/Software/libtorch/share/cmake/Torch"
export LD_LIBRARY_PATH="${HOME}/Software/libtorch/lib:$LD_LIBRARY_PATH"

# TensorRT (JetPack system install)
export LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH"

# OpenCV (JetPack system install — already CUDA-enabled)
# No special env needed; find_package(OpenCV) picks up system OpenCV.

# Limit CUDA memory allocator fragmentation on shared-memory Jetson devices.
# The 8 GB Orin Nano shares memory between CPU and GPU; a lower max-split-size
# reduces waste from PyTorch's caching allocator.
export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-max_split_size_mb:128}"

echo "[jetson_env] CUDA_HOME=$CUDA_HOME"
echo "[jetson_env] Torch_DIR=$Torch_DIR"
echo "[jetson_env] LD_LIBRARY_PATH set"
