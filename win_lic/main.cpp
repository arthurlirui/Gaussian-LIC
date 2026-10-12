/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * CLI entry point — replaces the ROS main() from src/mapping.cpp.
 *
 * Usage:
 *   winlic --config <config.yaml> [--result <path>] [--lpips <path>]
 *
 * The config YAML specifies:
 *   - dataset section (type: offline|orbbec, paths)
 *   - camera intrinsics
 *   - gaussian model parameters
 *   - depth_fusion options
 */

#include "core/params.h"
#include "core/pipeline.h"
#include "sensors/isensor_source.h"

#include <yaml-cpp/yaml.h>

#include <iostream>
#include <string>
#include <filesystem>

namespace fs = std::filesystem;

static void printUsage(const char* prog)
{
    std::cout << "Usage: " << prog << " --config <config.yaml> [options]\n"
              << "\nOptions:\n"
              << "  --config <path>    Path to YAML config file (required)\n"
              << "  --result <path>    Output directory for results (default: ./result)\n"
              << "  --lpips <path>     Path to LPIPS model directory (default: ./lpips)\n"
              << "  --help             Show this help message\n";
}

int main(int argc, char** argv)
{
    std::cout << "\n  WinLIC: Windows-Compatible Offline Multi-Modal "
              << "Gaussian Splatting Framework\n\n";

    std::string config_path;
    std::string result_path = "result";
    std::string lpips_path  = "lpips";

    // Parse command-line arguments
    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];
        if (arg == "--config" && i + 1 < argc)
        {
            config_path = argv[++i];
        }
        else if (arg == "--result" && i + 1 < argc)
        {
            result_path = argv[++i];
        }
        else if (arg == "--lpips" && i + 1 < argc)
        {
            lpips_path = argv[++i];
        }
        else if (arg == "--help" || arg == "-h")
        {
            printUsage(argv[0]);
            return 0;
        }
    }

    if (config_path.empty())
    {
        std::cerr << "Error: --config is required\n\n";
        printUsage(argv[0]);
        return 1;
    }

    if (!fs::exists(config_path))
    {
        std::cerr << "Error: Config file not found: " << config_path << "\n";
        return 1;
    }

    // Load config
    YAML::Node config = YAML::LoadFile(config_path);

    // Create output directory
    fs::create_directories(result_path);

    // Build parameters
    winlic::Params params(config);

    // Create sensor source
    auto source = winlic::createSensorSource(config);
    if (!source)
    {
        std::cerr << "Error: Failed to create sensor source\n";
        return 1;
    }

    // Open the source
    if (!source->open(config))
    {
        std::cerr << "Error: Failed to open sensor source\n";
        return 1;
    }

    // Create and run pipeline
    winlic::Pipeline pipeline(params, result_path, lpips_path);
    pipeline.run(*source);

    return 0;
}
