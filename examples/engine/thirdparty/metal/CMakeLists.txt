# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool)

# Metal, macOS and iOS only. Resolved as Apple system frameworks; no download needed.
# Metal, MetalKit, and Foundation are always available on every Apple platform.
gpStartThirdparty("metal" VERSION "any")
  gpThirdpartyRequiresPlatforms(macOS iOS)
  gpThirdpartySystem(
    FRAMEWORK Metal MetalKit Foundation
  )
gpEndThirdparty()
