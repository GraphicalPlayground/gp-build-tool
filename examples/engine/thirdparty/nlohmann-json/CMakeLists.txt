# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool)

# nlohmann/json, cross-platform, header-only JSON library.
# Resolution strategy (AUTO mode):
#   1. SYSTEM: use find_package if the library is already installed on the machine.
#   2. SOURCE fallback: download and configure from the GitHub archive.
#
# The HASH line is intentionally left commented out to keep this example runnable
# without pre-computing checksums. Uncomment and fill it in for production projects,
# it prevents supply-chain attacks by verifying the downloaded archive.
gpStartThirdparty("nlohmann-json" VERSION "3.11.3")
  gpThirdpartySystem(
    FIND_PACKAGE nlohmann_json
    TARGET       nlohmann_json::nlohmann_json
  )
  gpThirdpartySource(
    URL    "https://github.com/nlohmann/json/archive/refs/tags/v3.11.3.tar.gz"
    # HASH "SHA256=..."  # recommended for production, run cmake -E sha256sum on the archive
    TARGET "nlohmann_json::nlohmann_json"
  )
  gpThirdpartySetCMakeArgs(
    JSON_BuildTests=OFF
    JSON_Install=OFF
  )
gpEndThirdparty()
