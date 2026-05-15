# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/platforms/default)

# TODO: Windows-specific platform setup.
# Planned additions:
#   - _WIN32_WINNT targeting (e.g. 0x0A00 for Windows 10+) and WINVER
#   - WIN32_LEAN_AND_MEAN and NOMINMAX to avoid Windows.h pollution
#   - Unicode entry point: -DUNICODE -D_UNICODE
#   - DirectX SDK / Windows SDK path resolution
