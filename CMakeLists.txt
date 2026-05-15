# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

cmake_minimum_required(VERSION 3.28)

# Set the project name and version
project(gp-build-tool)

# Set the C++ standard to C++23 and disable compiler extensions
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add the source directory to the module path and include the GPBT build tool module
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/source")
include(gp-build-tool)

# Either run the GPBT tests or configure the example targets, depending on the GPBT_TESTS_ENABLED flag
if(GPBT_TESTS_ENABLED)
  return()
else()
  add_subdirectory(examples/engine)
endif()
