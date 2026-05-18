# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool)

gpStartModule(rhi/d3d12)
  gpAddDependency(PUBLIC rhi/base)
  gpAddDependency(PUBLIC core)
  if(WIN32)
    gpAddDependency(PRIVATE gp::thirdparty::d3d12)
  endif()
gpEndModule()
