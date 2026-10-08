cmake_minimum_required(VERSION 3.0.2)
project(gaussian_lic)

SET(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -Wall -g -Wno-sign-compare -Wno-unused -Wno-comment -pthread")

# ---------------------------------------------------------------------------
# Platform detection: Jetson (aarch64) vs x86_64
# ---------------------------------------------------------------------------
# On Jetson (aarch64) we must NOT pass -msse4.2 (x86-only) and we must target
# the correct CUDA arch (sm_87 for Orin).  x86_64 keeps the original behaviour.
# ---------------------------------------------------------------------------
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
  set(JETSON ON BOOL "Building on Jetson / aarch64")
  message(STATUS "[Gaussian-LIC] aarch64 detected — enabling Jetson build profile")
  # NEON is enabled by default on aarch64; no extra flag needed.
  set(GAUSSIAN_LIC_CUDA_ARCH "87" CACHE STRING "CUDA compute capability for Jetson (sm_87 = Orin)")
else()
  set(JETSON OFF)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -msse4.2")
  # x86 dev machine: let nvcc pick the default arch (sm_86/89 for RTX 30xx/40xx)
  set(GAUSSIAN_LIC_CUDA_ARCH "" CACHE STRING "CUDA compute capability (empty = nvcc default)")
endif()

find_package(catkin REQUIRED COMPONENTS
  roscpp
  rospy
  roslib
  std_msgs
  cv_bridge
  image_transport
  pcl_conversions
  pcl_ros
  std_msgs
  nav_msgs
  sensor_msgs
  geometry_msgs
  tf
  eigen_conversions
)

# ---------------------------------------------------------------------------
# Dependency paths — overridable cache variables with sensible defaults
# ---------------------------------------------------------------------------
# x86 dev machine defaults preserve the original ~/Software/... layout.
# On Jetson, pass -DOPENCV_DIR=... -DTorch_DIR=... etc. (or source jetson_env.sh)
# to point at JetPack system installations or extracted LibTorch.

# OpenCV
if(JETSON)
  # JetPack ships OpenCV with CUDA in the system prefix; use find_package default.
  set(OPENCV_DIR "" CACHE PATH "OpenCV build dir (empty = system)")
else()
  set(OPENCV_DIR "$ENV{HOME}/Software/opencv/opencv-4.7.0/build" CACHE PATH "OpenCV build dir")
endif()
if(OPENCV_DIR)
  set(OpenCV_DIR ${OPENCV_DIR})
endif()
find_package(OpenCV 4 REQUIRED)

# LibTorch
if(JETSON)
  set(Torch_DIR "$ENV{HOME}/Software/libtorch/share/cmake/Torch" CACHE PATH "LibTorch cmake dir")
else()
  set(Torch_DIR "$ENV{HOME}/Software/libtorch/share/cmake/Torch" CACHE PATH "LibTorch cmake dir")
endif()
find_package(Torch REQUIRED)

# TensorRT
if(JETSON)
  # JetPack: TensorRT installed via apt — libs in /usr/lib/aarch64-linux-gnu,
  # headers in /usr/include/aarch64-linux-gnu.  If using a tar extract, set
  # TENSORRT_ROOT to that directory instead.
  set(TENSORRT_ROOT "/usr" CACHE PATH "TensorRT root")
  set(TENSORRT_INCLUDE_DIR "${TENSORRT_ROOT}/include/aarch64-linux-gnu")
  set(TENSORRT_LIB_DIR "${TENSORRT_ROOT}/lib/aarch64-linux-gnu")
else()
  set(TENSORRT_ROOT "$ENV{HOME}/Software/TensorRT-8.6.1.6" CACHE PATH "TensorRT root")
  set(TENSORRT_INCLUDE_DIR "${TENSORRT_ROOT}/include")
  set(TENSORRT_LIB_DIR "${TENSORRT_ROOT}/lib")
endif()

# CUDA toolkit
if(JETSON)
  set(CUDA_TOOLKIT_ROOT_DIR "/usr/local/cuda" CACHE PATH "CUDA toolkit root")
else()
  set(CUDA_TOOLKIT_ROOT_DIR "/usr/local/cuda-11.7" CACHE PATH "CUDA toolkit root")
endif()
set(CUDA_INCLUDE_DIRS "${CUDA_TOOLKIT_ROOT_DIR}/include")
set(CUDA_LIB_DIR "${CUDA_TOOLKIT_ROOT_DIR}/lib64")
find_package(CUDA REQUIRED)
find_library(FFI_LIB ffi)

find_package(PkgConfig REQUIRED)
pkg_check_modules(YAML_CPP REQUIRED yaml-cpp>=0.5)

find_package(Python3 COMPONENTS Interpreter Development NumPy REQUIRED)

catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES gaussian_lic
#  CATKIN_DEPENDS roscpp rospy std_msgs
#  DEPENDS system_lib
)

include_directories(
# include
  src
  ${catkin_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIRS}
  ${YAML_INCLUDE_DIRS}
  ${Python3_INCLUDE_DIRS}
  ${TENSORRT_INCLUDE_DIR}
  ${CUDA_INCLUDE_DIRS}
)

# ---------------------------------------------------------------------------
# CUDA architecture flags
# ---------------------------------------------------------------------------
if(GAUSSIAN_LIC_CUDA_ARCH)
  set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}
    -gencode arch=compute_${GAUSSIAN_LIC_CUDA_ARCH},code=sm_${GAUSSIAN_LIC_CUDA_ARCH})
  message(STATUS "[Gaussian-LIC] CUDA arch: sm_${GAUSSIAN_LIC_CUDA_ARCH}")
endif()

add_executable(gs_mapping
              ${PROJECT_SOURCE_DIR}/src/mapping.cpp
              ${PROJECT_SOURCE_DIR}/src/gaussian.cpp
              ${PROJECT_SOURCE_DIR}/src/tinyply.cpp
              ${PROJECT_SOURCE_DIR}/src/depth_completer.cpp
              ${PROJECT_SOURCE_DIR}/src/simple-knn/spatial.cu
              ${PROJECT_SOURCE_DIR}/src/simple-knn/simple_knn.cu
              ${PROJECT_SOURCE_DIR}/src/fused-ssim/ssim.cu
              ${PROJECT_SOURCE_DIR}/src/rasterizer/renderer.cpp
              ${PROJECT_SOURCE_DIR}/src/rasterizer/rasterizer.cpp
              ${PROJECT_SOURCE_DIR}/src/rasterizer/rasterize_points.cu
              ${PROJECT_SOURCE_DIR}/src/rasterizer/cuda_rasterizer/adam.cu
              ${PROJECT_SOURCE_DIR}/src/rasterizer/cuda_rasterizer/forward.cu
              ${PROJECT_SOURCE_DIR}/src/rasterizer/cuda_rasterizer/backward.cu
              ${PROJECT_SOURCE_DIR}/src/rasterizer/cuda_rasterizer/rasterizer_impl.cu)
target_link_libraries(gs_mapping
                      ${catkin_LIBRARIES}
                      ${OpenCV_LIBS}
                      ${TORCH_LIBRARIES}
                      ${YAML_CPP_LIBRARIES}
                      ${Python3_LIBRARIES}
                      ${FFI_LIB}
                      ${CUDA_LIB_DIR}/libcudart.so
                      ${TENSORRT_LIB_DIR}/libnvinfer.so
                      ${TENSORRT_LIB_DIR}/libnvonnxparser.so
                      ${TENSORRT_LIB_DIR}/libnvparsers.so
                      ${TENSORRT_LIB_DIR}/libnvinfer_plugin.so)
