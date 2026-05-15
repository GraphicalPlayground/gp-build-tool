# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/platforms/default)
include(gp-build-tool/platforms/unix)

# TODO: Android-specific platform setup.
# Planned additions:
#   - -DANDROID and __ANDROID_API__ targeting (via CMAKE_ANDROID_API or ANDROID_PLATFORM)
#   - NDK STL selection (libc++ via CMAKE_ANDROID_STL_TYPE = c++_shared / c++_static)
#   - .so naming and ABI filter (arm64-v8a, armeabi-v7a, x86_64) via CMAKE_ANDROID_ARCH_ABI
#   - Link against -landroid -llog for Android-specific system APIs
#   - Strip debug info for release .so files (implicit with Shipping flags)
