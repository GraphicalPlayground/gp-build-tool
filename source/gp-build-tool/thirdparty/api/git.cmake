# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Declare a Git repository as the source for this package.
# @param[in] REPOSITORY    Git clone URL (HTTPS or SSH).
# @param[in] TAG           Commit hash, branch name, or tag name.
# @param[in] SHALLOW       (Flag) Enable a shallow clone (--depth 1). Only valid for named
#                          refs (branches and tags). Do NOT combine with a raw commit hash.
# @param[in] TARGET        (Optional) CMake target name exported by the subproject after
#                          FetchContent_MakeAvailable. Defaults to "<cleanName>::<cleanName>".
# @param[in] PATCH_COMMAND (Optional, multi-value) Command tokens run once in the source
#                          directory after the initial clone. Applied only on the first
#                          populate; subsequent reconfigures reuse the cached tree.
#                          Example: git apply ${CMAKE_CURRENT_LIST_DIR}/my.patch
# @remarks
#   Only one git or source declaration is allowed per package.
#   Call within a gpStartThirdparty / gpEndThirdparty block.
#   The resolved package is exposed as gp::thirdparty::<cleanName>.
function(gpbt_thirdpartyGit)
  gpbt_checkInThirdpartyDefinition("gpbt_thirdpartyGit")

  cmake_parse_arguments(_GIT "SHALLOW" "REPOSITORY;TAG;TARGET" "PATCH_COMMAND" ${ARGN})

  if(NOT _GIT_REPOSITORY)
    gpbt_log(FATAL "gpThirdpartyGit: REPOSITORY is required")
  endif()
  if(NOT _GIT_TAG)
    gpbt_log(FATAL "gpThirdpartyGit: TAG is required")
  endif()

  # Warn on duplicate source/git declaration
  gpbt_getScopedProperty(_packageSourceType _existingType)
  if(_existingType)
    gpbt_getScopedProperty(_packageName _name)
    gpbt_log(WARNING "gpThirdpartyGit: a source declaration already exists for '${_name}', overwriting")
  endif()

  gpbt_setScopedProperty(_packageSourceType    "GIT")
  gpbt_setScopedProperty(_packageGitRepository "${_GIT_REPOSITORY}")
  gpbt_setScopedProperty(_packageGitTag        "${_GIT_TAG}")
  gpbt_setScopedProperty(_packageGitShallow    "${_GIT_SHALLOW}")
  gpbt_setScopedProperty(_packageSourceTarget  "${_GIT_TARGET}")
  gpbt_setScopedProperty(_packagePatchCommand  "${_GIT_PATCH_COMMAND}")

  gpbt_log(VERBOSE "  Git repository: ${_GIT_REPOSITORY} @ ${_GIT_TAG}")
endfunction()
