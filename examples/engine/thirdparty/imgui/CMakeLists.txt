# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground.com/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool)

# Dear ImGui (docking branch) - core library only.
# Dear ImGui does not ship an official CMake build system; GPBT downloads the source
# archive and generates the gp::thirdparty::imgui static library target directly.
# No pre-made platform or renderer backend is included because the engine owns
# rendering, input handling, texture binding, and platform integration via its RHI.
gpStartThirdparty("imgui" VERSION "1.93.1")
  gpThirdpartySource(
    URL  "https://github.com/ocornut/imgui/archive/refs/tags/v1.93.1-docking.tar.gz"
    HASH "SHA256=055a0b9023905e7ad9c0852706a7b19ca4cc8a34e56f4b25732edb9d8efda961"
  )

  gpThirdpartySetLibraryType(STATIC)

  gpThirdpartySetSources(
    imgui.cpp
    imgui_draw.cpp
    imgui_tables.cpp
    imgui_widgets.cpp
  )

  gpThirdpartySetIncludeDirectories(".")
gpEndThirdparty()
