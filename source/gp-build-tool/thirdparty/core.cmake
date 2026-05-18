# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(FetchContent)

include(gp-build-tool/utilities/logger)
include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/strings)
include(gp-build-tool/thirdparty/api/declare)
include(gp-build-tool/thirdparty/api/source)
include(gp-build-tool/thirdparty/api/binary)
include(gp-build-tool/thirdparty/api/system)
include(gp-build-tool/thirdparty/api/requirements)
include(gp-build-tool/thirdparty/api/cmake-args)
include(gp-build-tool/thirdparty/api/mode)
include(gp-build-tool/thirdparty/resolve)

# Detect and cache the current platform as a GP platform token.
# Token values: Windows | macOS | iOS | Android | Linux | FreeBSD | Unknown
if(WIN32)
  set(GPBT_CURRENT_PLATFORM "Windows")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
  set(GPBT_CURRENT_PLATFORM "Android")
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
  set(GPBT_CURRENT_PLATFORM "iOS")
elseif(APPLE)
  set(GPBT_CURRENT_PLATFORM "macOS")
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
  set(GPBT_CURRENT_PLATFORM "FreeBSD")
elseif(UNIX)
  set(GPBT_CURRENT_PLATFORM "Linux")
else()
  set(GPBT_CURRENT_PLATFORM "Unknown")
endif()

# Detect and cache the current compiler as a GP compiler token.
# Token values: MSVC | Clang | Clang-CL | GCC | Unknown
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(GPBT_CURRENT_COMPILER "MSVC")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    set(GPBT_CURRENT_COMPILER "Clang-CL")
  else()
    set(GPBT_CURRENT_COMPILER "Clang")
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(GPBT_CURRENT_COMPILER "GCC")
else()
  set(GPBT_CURRENT_COMPILER "Unknown")
endif()

gpbt_log(VERBOSE "Thirdparty system initialized - platform: ${GPBT_CURRENT_PLATFORM}, compiler: ${GPBT_CURRENT_COMPILER}")
