# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

# Default platform baseline, included by every platform file.
# Planned additions:
#   - Architecture detection (x86_64, arm64, armv7) and per-arch compile flags
#   - SIMD capability flags (-mavx2, -mfpu=neon, /arch:AVX2) gated on a GPBT_TARGET_ARCH option
