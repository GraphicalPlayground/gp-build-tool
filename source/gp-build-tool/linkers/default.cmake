# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/compilers/default)

# Linker default stub; included first by every linker file.
# gpbt_applyLinkerFlags() is already defined as a no-op in compilers/default.cmake;
# each linker specialization overrides it.
