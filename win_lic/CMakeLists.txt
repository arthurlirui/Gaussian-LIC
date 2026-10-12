# ===========================================================================
# WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
# CMakeLists.txt — Windows (MSVC) / Linux (GCC) build without ROS/catkin
# ===========================================================================
cmake_minimum_required(VERSION 3.18)
project(win_lic LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ---------------------------------------------------------------------------
# Build type
# ---------------------------------------------------------------------------
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

# ---------------------------------------------------------------------------
# Compiler flags
# ---------------------------------------------------------------------------
if(MSVC)
  # MSVC (Windows) flags
  set(CMAKE_CXX_FLAGS_RELEASE "/O2 /W3 /EHsc /DNDEBUG")
  set(CMAKE_CUDA_FLAGS_RELEASE "-O2 -DNDEBUG")
  # Suppress MSVC warnings about deprecated functions
  add_compile_definitions(_CRT_SECURE_NO_WARNINGS _WINSOCK_DEPRECATED_NO_WARNINGS)
  # Big-object support (some CUDA-generated files are large)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
else()
  # GCC / Clang (Linux) flags
  set(CMAKE_CXX_FLAGS_RELEASE "-O3 -Wall -Wno-sign-compare -Wno-unused -Wno-comment -pthread")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse4.2")
endif()

# ---------------------------------------------------------------------------
# CUDA architecture
# ---------------------------------------------------------------------------
# Let user override; default to sm_89 (RTX 40xx) on x86, sm_87 on Jetson.
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
  set(GAUSSIAN_LIC_CUDA_ARCH "87" CACHE STRING "CUDA compute capability")
else()
  set(GAUSSIAN_LIC_CUDA_ARCH "89" CACHE STRING "CUDA compute capability (empty = nvcc default)")
endif()
if(GAUSSIAN_LIC_CUDA_ARCH)
  set(CMAKE_CUDA_ARCHITECTURES ${GAUSSIAN_LIC_CUDA_ARCH})
  message(STATUS "[WinLIC] CUDA arch: sm_${GAUSSIAN_LIC_CUDA_ARCH}")
else()
  set(CMAKE_CUDA_ARCHITECTURES native)
endif()

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------

# OpenCV
find_package(OpenCV 4 REQUIRED)

# LibTorch (PyTorch C++ API)
# Set -DTorch_DIR=<path>/libtorch/share/cmake/Torch
find_package(Torch REQUIRED)

# yaml-cpp
find_package(yaml-cpp REQUIRED)

# TensorRT (for depth completion via SPNet)
# Set -DTENSORRT_ROOT=<path>
if(NOT TENSORRT_ROOT)
  if(MSVC)
    set(TENSORRT_ROOT "C:/Program Files/NVIDIA GPU Computing/TensorRT" CACHE PATH "TensorRT root")
  else()
    set(TENSORRT_ROOT "$ENV{HOME}/Software/TensorRT-8.6.1.6" CACHE PATH "TensorRT root")
  endif()
endif()
set(TENSORRT_INCLUDE_DIR "${TENSORRT_ROOT}/include")
if(MSVC)
  set(TENSORRT_LIB_DIR "${TENSORRT_ROOT}/lib")
else()
  set(TENSORRT_LIB_DIR "${TENSORRT_ROOT}/lib")
endif()

# Python3 (for LibTorch's numpy interop)
find_package(Python3 COMPONENTS Interpreter Development NumPy REQUIRED)

# Orbbec SDK (optional — compile-gated)
option(USE_ORBBEC_SDK "Enable Orbbec SDK live camera support" OFF)
if(USE_ORBBEC_SDK)
  if(NOT OrbbecSDK_DIR)
    message(FATAL_ERROR "USE_ORBBEC_SDK=ON but OrbbecSDK_DIR not set. "
      "Point it to the OrbbecSDK v2 install directory.")
  endif()
  find_package(OrbbecSDK REQUIRED)
  add_compile_definitions(USE_ORBBEC_SDK)
  message(STATUS "[WinLIC] Orbbec SDK support: ENABLED")
else()
  message(STATUS "[WinLIC] Orbbec SDK support: disabled (stub mode)")
endif()

# ---------------------------------------------------------------------------
# Include directories
# ---------------------------------------------------------------------------
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/utils
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda
  ${OpenCV_INCLUDE_DIRS}
  ${TORCH_INCLUDE_DIRS}
  ${YAML_CPP_INCLUDE_DIR}
  ${Python3_INCLUDE_DIRS}
  ${TENSORRT_INCLUDE_DIR}
)

if(USE_ORBBEC_SDK)
  include_directories(${OrbbecSDK_INCLUDE_DIRS})
endif()

# ---------------------------------------------------------------------------
# Sources
# ---------------------------------------------------------------------------
set(WINLIC_SOURCES
  # Core pipeline
  ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/core/pipeline.cpp

  # Sensors
  ${CMAKE_CURRENT_SOURCE_DIR}/sensors/isensor_source.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/sensors/dataset_reader.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/sensors/orbbec_source.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/sensors/imu_io.cpp

  # Depth fusion
  ${CMAKE_CURRENT_SOURCE_DIR}/depth/depth_fusion.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/depth/depth_completer.cpp

  # Gaussian model
  ${CMAKE_CURRENT_SOURCE_DIR}/gaussians/gaussian_model.cpp

  # PLY I/O
  ${CMAKE_CURRENT_SOURCE_DIR}/utils/tinyply.cpp

  # CUDA kernels
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/simple-knn/spatial.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/simple-knn/simple_knn.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/fused-ssim/ssim.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/rasterizer/renderer.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/rasterizer/rasterizer.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/rasterizer/rasterize_points.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/rasterizer/cuda_rasterizer/adam.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/rasterizer/cuda_rasterizer/forward.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/rasterizer/cuda_rasterizer/backward.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/cuda/rasterizer/cuda_rasterizer/rasterizer_impl.cu
)

# ---------------------------------------------------------------------------
# Executable
# ---------------------------------------------------------------------------
add_executable(winlic ${WINLIC_SOURCES})

# ---------------------------------------------------------------------------
# Link libraries
# ---------------------------------------------------------------------------
target_link_libraries(winlic
  ${OpenCV_LIBS}
  ${TORCH_LIBRARIES}
  ${YAML_CPP_LIBRARIES}
  ${Python3_LIBRARIES}
)

# TensorRT libraries
if(MSVC)
  target_link_libraries(winlic
    ${TENSORRT_LIB_DIR}/nvinfer.lib
    ${TENSORRT_LIB_DIR}/nvonnxparser.lib
    ${TENSORRT_LIB_DIR}/nvparsers.lib
    ${TENSORRT_LIB_DIR}/nvinfer_plugin.lib
  )
else()
  target_link_libraries(winlic
    ${TENSORRT_LIB_DIR}/libnvinfer.so
    ${TENSORRT_LIB_DIR}/libnvonnxparser.so
    ${TENSORRT_LIB_DIR}/libnvparsers.so
    ${TENSORRT_LIB_DIR}/libnvinfer_plugin.so
  )
endif()

# Orbbec SDK
if(USE_ORBBEC_SDK)
  target_link_libraries(winlic ${OrbbecSDK_LIBRARIES})
endif()

# ---------------------------------------------------------------------------
# Copy config to build directory
# ---------------------------------------------------------------------------
add_custom_command(TARGET winlic POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  ${CMAKE_CURRENT_SOURCE_DIR}/config
  $<TARGET_FILE_DIR:winlic>/config
)

# ---------------------------------------------------------------------------
# Messages
# ---------------------------------------------------------------------------
message(STATUS "[WinLIC] Configuration complete.")
message(STATUS "  OpenCV:   ${OpenCV_VERSION}")
message(STATUS "  LibTorch: ${Torch_VERSION}")
message(STATUS "  TensorRT: ${TENSORRT_ROOT}")
message(STATUS "  Build:    ${CMAKE_BUILD_TYPE}")
