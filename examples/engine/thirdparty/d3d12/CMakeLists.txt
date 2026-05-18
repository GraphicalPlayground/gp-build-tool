# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool)

# DirectX 12, Windows-only. Always resolved from the Windows SDK; no download needed.
# The SDK is part of every Windows development environment and GitHub Actions Windows runner.
gpStartThirdparty("d3d12" VERSION "sdk")
  gpThirdpartyRequiresPlatforms(Windows)
  gpThirdpartySystem(
    WINDOWS_SDK
    LIBS d3d12 dxgi dxguid d3dcompiler
  )
gpEndThirdparty()
