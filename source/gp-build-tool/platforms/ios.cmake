# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/platforms/default)
include(gp-build-tool/platforms/unix)

# TODO: iOS-specific platform setup.
# Planned additions:
#   - Minimum deployment target via CMAKE_OSX_DEPLOYMENT_TARGET (e.g. "16.0")
#   - SDK selection: CMAKE_OSX_SYSROOT = iphoneos | iphonesimulator
#   - Bitcode: -fembed-bitcode (required for App Store) vs -fembed-bitcode-marker
#   - Code signing: CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY and DEVELOPMENT_TEAM
#   - Fat/universal binary support via CMAKE_OSX_ARCHITECTURES (arm64;x86_64)
#   - Framework bundling rules for .framework targets
