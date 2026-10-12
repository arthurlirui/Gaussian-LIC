/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Abstract sensor source interface.
 * Any data input — offline file reader, Orbbec SDK live camera, or a future
 * SDK — implements this interface so the downstream pipeline is agnostic
 * to the data origin.
 */

#pragma once

#include <yaml-cpp/yaml.h>
#include <memory>
#include <string>
#include "core/types.h"

namespace winlic {

/// Abstract interface for a multi-modal sensor data source.
///
/// Lifecycle:
///   1. open(config)  — initialise the source (open files, start camera stream)
///   2. hasNext()     — poll whether more frames are available
///   3. nextFrame()   — retrieve the next AlignedFrame (blocking if live source)
///   4. close()       — release resources
///
/// For offline file readers, nextFrame() returns immediately; for live camera
/// sources it may block until the next frame arrives.
class ISensorSource
{
public:
    virtual ~ISensorSource() = default;

    /// Initialise the source from a YAML config node.
    /// Returns true on success.
    virtual bool open(const YAML::Node& config) = 0;

    /// Returns true if there is at least one more frame to read.
    virtual bool hasNext() = 0;

    /// Retrieve the next aligned frame.
    /// The caller must check hasNext() first.
    virtual AlignedFrame nextFrame() = 0;

    /// Release any held resources (files, device handles, streams).
    virtual void close() = 0;

    /// Human-readable name of this source (e.g. "DatasetReader", "OrbbecSource").
    virtual std::string name() const = 0;
};

/// Factory: create a sensor source from a YAML config node.
/// Reads `dataset.type` ("offline" | "orbbec") and instantiates accordingly.
std::unique_ptr<ISensorSource> createSensorSource(const YAML::Node& config);

}  // namespace winlic
