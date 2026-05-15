# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/platforms/default)

# TODO: POSIX/Unix shared setup (included by linux.cmake, macos.cmake, freebsd.cmake).
# Planned additions:
#   - _POSIX_C_SOURCE / _XOPEN_SOURCE version targeting for strict POSIX conformance
#   - RPATH handling (CMAKE_INSTALL_RPATH, CMAKE_BUILD_WITH_INSTALL_RPATH)
