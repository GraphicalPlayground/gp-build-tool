# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/platforms/default)
include(gp-build-tool/platforms/unix)

# TODO: FreeBSD-specific platform setup.
# FreeBSD shares most flags with Linux (ELF, --gc-sections, Clang as system compiler).
# Planned additions:
#   - FreeBSD ports include/lib prefix (/usr/local) may need to be added to search paths
#   - Vulkan loader path differs from Linux (/usr/local/lib vs /usr/lib)
