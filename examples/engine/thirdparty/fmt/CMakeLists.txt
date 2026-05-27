# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include(gp-build-tool)

# {fmt}, a fast and type-safe formatting library.
# Resolution strategy (AUTO mode):
#   1. SYSTEM: use find_package if fmt is already installed on the machine.
#   2. GIT fallback: clone the exact tagged commit from GitHub and build from source.
#
# The TAG below is a full commit hash pinned to v10.2.1.  Using a commit hash instead
# of a mutable branch name guarantees reproducible builds: the same hash always yields
# the same source tree, regardless of what happens to the upstream repository.
#
# Alternative: shallow-clone using the tag name (faster download, still reproducible):
#
#   gpThirdpartyGit(
#     REPOSITORY "https://github.com/fmtlib/fmt.git"
#     TAG        "v10.2.1"
#     SHALLOW
#     TARGET     "fmt::fmt"
#   )
#
# Do NOT combine SHALLOW with a raw commit hash; git shallow clones require a named
# ref (branch or tag) as the target.
gpStartThirdparty("fmt" VERSION "10.2.1")
  gpThirdpartySystem(
    FIND_PACKAGE fmt
    TARGET       fmt::fmt
  )
  gpThirdpartyGit(
    REPOSITORY "https://github.com/fmtlib/fmt.git"
    TAG        "e69e5f977d458f2650bb346dadf2ad30c5320281"
    TARGET     "fmt::fmt"
  )
  gpThirdpartySetCMakeArgs(
    FMT_TEST=OFF
    FMT_DOC=OFF
    FMT_INSTALL=OFF
  )
gpEndThirdparty()
