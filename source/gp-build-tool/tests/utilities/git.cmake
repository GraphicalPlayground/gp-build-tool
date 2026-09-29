# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground.com/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/tests/asserts)
include(gp-build-tool/utilities/git)

gpbt_startTestSection("Git: Is git Available")
  gpbt_isGitAvailable(gitAvailable)
  gpbt_assertEqual("${gitAvailable}" "TRUE" "Expected Git to be available on the system")
gpbt_endTestSection()

gpbt_startTestSection("Git: Is git Repository")
  gpbt_isGitRepository(isRepo)
  gpbt_assertEqual("${isRepo}" "TRUE" "Expected the current directory to be inside a Git repository")
gpbt_endTestSection()

# We cannot reliably test the other Git functions (like getting the branch, commit hash, etc.)
# because they depend on the specific state of the Git repository in which this test is run.
# Therefore, we will not include tests for those functions here.
