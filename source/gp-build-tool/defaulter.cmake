# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool/utilities/logger)
include(gp-build-tool/config)

# Check if the generator is Multi-Config (Visual Studio / Xcode) or Single-Config (Ninja / Make)
get_property(IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTI_CONFIG)
  # For Visual Studio / Xcode:
  # This directly populates the configuration dropdown in the IDE.
  set(CMAKE_CONFIGURATION_TYPES "${GPBT_ALLOWED_CONFIGS}" CACHE STRING "Build Configurations" FORCE)
else()
  # For Ninja / Makefiles:
  # Set a default build type if the user didn't specify one via command line
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Development" CACHE STRING "Choose the type of build." FORCE)
  endif()

  # Provide a dropdown menu for CMake GUI tools (ccmake, cmake-gui)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${GPBT_ALLOWED_CONFIGS})

  # Validate that the user didn't type something invalid like -DCMAKE_BUILD_TYPE=Potato
  if(NOT CMAKE_BUILD_TYPE IN_LIST GPBT_ALLOWED_CONFIGS)
    gpbt_log(FATAL "Invalid CMAKE_BUILD_TYPE: '${CMAKE_BUILD_TYPE}'. " "Allowed values are: ${GPBT_ALLOWED_CONFIGS}")
  endif()
endif()

# DEVELOPMENT: Map it to behave like RelWithDebInfo natively
set(CMAKE_C_FLAGS_DEVELOPMENT "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "Flags for Development" FORCE)
set(CMAKE_CXX_FLAGS_DEVELOPMENT "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "Flags for Development" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_DEVELOPMENT "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "Linker flags for Development" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_DEVELOPMENT "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "Shared Linker flags for Development" FORCE)
set(CMAKE_STATIC_LINKER_FLAGS_DEVELOPMENT "${CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "Static Linker flags for Development" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS_DEVELOPMENT "${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO}" CACHE STRING "Module Linker flags for Development" FORCE)

# PROFILE: Map it to behave like Release natively
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "Flags for Profile" FORCE)
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING "Flags for Profile" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags for Profile" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}" CACHE STRING "Shared Linker flags for Profile" FORCE)
set(CMAKE_STATIC_LINKER_FLAGS_PROFILE "${CMAKE_STATIC_LINKER_FLAGS_RELEASE}" CACHE STRING "Static Linker flags for Profile" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS_PROFILE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}" CACHE STRING "Module Linker flags for Profile" FORCE)

# SHIPPING: Map it to behave like Release natively
set(CMAKE_C_FLAGS_SHIPPING "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "Flags for Shipping" FORCE)
set(CMAKE_CXX_FLAGS_SHIPPING "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING "Flags for Shipping" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_SHIPPING "${CMAKE_EXE_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags for Shipping" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_SHIPPING "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}" CACHE STRING "Shared Linker flags for Shipping" FORCE)
set(CMAKE_STATIC_LINKER_FLAGS_SHIPPING "${CMAKE_STATIC_LINKER_FLAGS_RELEASE}" CACHE STRING "Static Linker flags for Shipping" FORCE)
set(CMAKE_MODULE_LINKER_FLAGS_SHIPPING "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}" CACHE STRING "Module Linker flags for Shipping" FORCE)

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

# If the build is not a monolithic build, set the default library type to OBJECT. Otherwise, set it to STATIC.
if(NOT GPBT_IS_MONOLITHIC)
  set(BUILD_SHARED_LIBS ON CACHE BOOL "Whether to build shared libraries." FORCE)
  gpbt_log(INFO "GPBT_IS_MONOLITHIC is OFF. Defaulting to building shared libraries.")
else()
  set(BUILD_SHARED_LIBS OFF CACHE BOOL "Whether to build shared libraries." FORCE)
  gpbt_log(INFO "GPBT_IS_MONOLITHIC is ON. Defaulting to building static libraries.")
endif()
