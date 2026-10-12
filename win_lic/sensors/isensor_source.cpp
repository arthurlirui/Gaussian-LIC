/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Sensor source factory implementation.
 */

#include "isensor_source.h"
#include "dataset_reader.h"
#include "orbbec_source.h"
#include <iostream>

namespace winlic {

std::unique_ptr<ISensorSource> createSensorSource(const YAML::Node& config)
{
    std::string type = "offline";
    if (config["dataset"] && config["dataset"]["type"])
    {
        type = config["dataset"]["type"].as<std::string>();
    }

    if (type == "offline")
    {
        return std::make_unique<DatasetReader>();
    }
    else if (type == "orbbec")
    {
        return std::make_unique<OrbbecSource>();
    }
    else
    {
        std::cerr << "[createSensorSource] Unknown dataset type: " << type
                  << " (expected 'offline' or 'orbbec')\n";
        return nullptr;
    }
}

}  // namespace winlic
