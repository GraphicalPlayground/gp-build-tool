# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/logger)

# Set the default build type to Release if not specified by the user.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)
  gpbt_log(LOG "No build type specified. Defaulting to Release.")
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Set the default CXX standard to C++23 if not specified by the user.
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23 CACHE STRING "The C++ standard to use when compiling." FORCE)
  set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "Whether the C++ standard is required or if a newer version can be used." FORCE)
  set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "Whether to allow compiler-specific extensions to the C++ standard." FORCE)
  gpbt_log(LOG "No C++ standard specified. Defaulting to C++23.")
endif()

# Set the usage of Compile Commands to ON if not specified by the user.
if(NOT CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Whether to generate a compile_commands.json file." FORCE)
  gpbt_log(LOG "No setting for CMAKE_EXPORT_COMPILE_COMMANDS specified. Defaulting to ON.")
endif()
