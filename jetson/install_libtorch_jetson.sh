#!/usr/bin/env bash
# ===========================================================================
# install_libtorch_jetson.sh — Extract LibTorch C++ libs from the Jetson
#                               PyTorch wheel for use in CMake
# ===========================================================================
# Gaussian-LIC uses LibTorch (the C++ PyTorch API) via find_package(Torch).
# On x86, a prebuilt libtorch zip is downloaded.  On Jetson/aarch64 there is no
# official libtorch zip — instead, NVIDIA ships a PyTorch pip wheel for Jetson
# that contains the same libtorch libraries inside.
#
# This script:
#   1. Downloads the NVIDIA Jetson PyTorch wheel (matching JetPack 5.x / CUDA 11.4)
#   2. Unpacks it to ~/Software/libtorch
#   3. Creates a CMake config so find_package(Torch) works
#
# Reference: https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform/
# ===========================================================================
set -e

# --- Configuration ---------------------------------------------------------
# JetPack 5.1.x → PyTorch 2.0.0+nv23.05, Python 3.8, CUDA 11.4
PYTORCH_WHL_URL="https://developer.download.nvidia.com/compute/redist/jp/v511/pytorch/torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl"
PYTORCH_WHL_NAME="torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl"

INSTALL_DIR="${HOME}/Software/libtorch"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo ">>> Installing LibTorch for Jetson (aarch64)"
echo "    Wheel: $PYTORCH_WHL_NAME"
echo "    Target: $INSTALL_DIR"

# --- Download wheel --------------------------------------------------------
cd "$WORK_DIR"
if [ ! -f "$PYTORCH_WHL_NAME" ]; then
  echo ">>> Downloading PyTorch wheel..."
  wget -q --show-progress "$PYTORCH_WHL_URL" -O "$PYTORCH_WHL_NAME"
fi

# --- Unpack wheel ----------------------------------------------------------
# A .whl is just a zip.  The libtorch libraries live under torch/lib/.
echo ">>> Unpacking wheel to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR"
unzip -q -o "$PYTORCH_WHL_NAME" -d "$WORK_DIR/unpacked"

# --- Layout for find_package(Torch) ---------------------------------------
# CMake's find_package(Torch) needs share/cmake/Torch/TorchConfig.cmake.
# The wheel ships cmake config files under torch/share/cmake/.
cp -r "$WORK_DIR/unpacked/torch" "$INSTALL_DIR/"

# The wheel stores .so files under torch/lib/.  find_package(Torch) and the
# linker need them in lib/.  Create a symlink.
mkdir -p "$INSTALL_DIR/lib"
for f in "$INSTALL_DIR/torch/lib/"*.so*; do
  ln -sf "$f" "$INSTALL_DIR/lib/$(basename "$f")"
done

# Copy cmake config to the standard location.
mkdir -p "$INSTALL_DIR/share/cmake"
if [ -d "$INSTALL_DIR/torch/share/cmake" ]; then
  cp -r "$INSTALL_DIR/torch/share/cmake/"* "$INSTALL_DIR/share/cmake/"
fi

# Some wheels put TorchConfig.cmake under torch/.  Create a symlink as fallback.
if [ -f "$INSTALL_DIR/torch/share/cmake/Torch/TorchConfig.cmake" ] && \
   [ ! -f "$INSTALL_DIR/share/cmake/Torch/TorchConfig.cmake" ]; then
  mkdir -p "$INSTALL_DIR/share/cmake/Torch"
  ln -sf "$INSTALL_DIR/torch/share/cmake/Torch/TorchConfig.cmake" \
         "$INSTALL_DIR/share/cmake/Torch/TorchConfig.cmake"
fi

echo ""
echo ">>> Done. LibTorch installed to: $INSTALL_DIR"
echo ">>> Use in CMake with:"
echo "    cmake .. -DTorch_DIR=$INSTALL_DIR/share/cmake/Torch"
echo ""
echo ">>> Make sure LD_LIBRARY_PATH includes the lib dir at runtime:"
echo "    export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH"
