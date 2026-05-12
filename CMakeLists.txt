# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

cmake_minimum_required(VERSION 3.28)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/source")

project(gp-build-tool)

include(gp-build-tool)

# Either run the GPBT tests or configure the example targets, depending on the GPBT_TESTS_ENABLED flag
if(GPBT_TESTS_ENABLED)
  return()
else()
  add_subdirectory(examples/engine)
endif()
