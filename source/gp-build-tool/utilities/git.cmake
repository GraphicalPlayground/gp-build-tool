# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground.com/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/logger)

find_package(Git QUIET)
if(NOT GIT_FOUND)
  gpbt_log(WARNING "Git not found. Some features may not work as expected.")
endif()

# @brief Executes a Git command and captures its output.
# @param[out] outputVariable The variable to store the output of the Git command.
# @param[in] ... The Git command and its arguments.
function(gpbt_runGitCommand outputVariable)
  if(NOT GIT_FOUND)
    set(${outputVariable} "" PARENT_SCOPE)
    return()
  endif()

  # Execute the Git command and capture the output
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ${ARGN}
    RESULT_VARIABLE _result
    OUTPUT_VARIABLE _output
    ERROR_VARIABLE _error
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(NOT _result EQUAL 0)
    gpbt_log(WARNING "Git command failed: ${_error}")
    set(${outputVariable} "" PARENT_SCOPE)
  else()
    set(${outputVariable} "${_output}" PARENT_SCOPE)
  endif()
endfunction()

# @brief Checks if Git is available on the system.
# @param[out] outputVariable The variable to store the result (TRUE if Git is available, FALSE otherwise).
function(gpbt_isGitAvailable outputVariable)
  if(GIT_FOUND)
    set(${outputVariable} TRUE PARENT_SCOPE)
  else()
    set(${outputVariable} FALSE PARENT_SCOPE)
  endif()
endfunction()

# @brief Retrieves the current Git branch name.
# @param[out] outputBranch The variable to store the current Git branch name.
function(gpbt_getGitBranch outputBranch)
  gpbt_runGitCommand(_branch rev-parse --abbrev-ref HEAD)
  set(${outputBranch} "${_branch}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the current Git commit hash.
# @param[out] outputHash The variable to store the current Git commit hash.
function(gpbt_getGitCommitHash outputHash)
  gpbt_runGitCommand(_hash rev-parse HEAD)
  set(${outputHash} "${_hash}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the short version of the current Git commit hash.
# @param[out] outputHash The variable to store the short Git commit hash.
function(gpbt_getShortGitCommitHash outputHash)
  gpbt_runGitCommand(_short_hash rev-parse --short HEAD)
  set(${outputHash} "${_short_hash}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the date of the current Git commit.
# @param[out] outputDate The variable to store the date of the current Git commit.
function(gpbt_getGitCommitDate outputDate)
  gpbt_runGitCommand(_date log -1 --format=%cd)
  set(${outputDate} "${_date}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the message of the current Git commit.
# @param[out] outputMessage The variable to store the message of the current Git commit.
function(gpbt_getGitCommitMessage outputMessage)
  gpbt_runGitCommand(_message log -1 --format=%B)
  set(${outputMessage} "${_message}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the author of the current Git commit.
# @param[out] outputAuthor The variable to store the author of the current Git commit.
function(gpbt_getGitCommitAuthor outputAuthor)
  gpbt_runGitCommand(_author log -1 --format=%an)
  set(${outputAuthor} "${_author}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the committer of the current Git commit.
# @param[out] outputCommitter The variable to store the committer of the current Git
function(gpbt_getGitCommitter outputCommitter)
  gpbt_runGitCommand(_committer log -1 --format=%cn)
  set(${outputCommitter} "${_committer}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the email of the author of the current Git commit.
# @param[out] outputEmail The variable to store the email of the author of the current Git commit.
function(gpbt_getGitCommitAuthorEmail outputEmail)
  gpbt_runGitCommand(_email log -1 --format=%ae)
  set(${outputEmail} "${_email}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the email of the committer of the current Git commit.
# @param[out] outputEmail The variable to store the email of the committer of the current Git commit.
function(gpbt_getGitCommitterEmail outputEmail)
  gpbt_runGitCommand(_email log -1 --format=%ce)
  set(${outputEmail} "${_email}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the remote URL of the Git repository.
# @param[out] outputUrl The variable to store the remote URL of the Git repository.
function(gpbt_getGitRemoteUrl outputUrl)
  gpbt_runGitCommand(_url remote get-url origin)
  set(${outputUrl} "${_url}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the name of the remote of the Git repository.
# @param[out] outputName The variable to store the name of the remote of the Git repository.
function(gpbt_getGitRemoteName outputName)
  gpbt_runGitCommand(_name remote)
  set(${outputName} "${_name}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the name of the remote branch of the Git repository.
# @param[out] outputBranch The variable to store the name of the remote branch of the Git repository.
function(gpbt_getGitRemoteBranch outputBranch)
  gpbt_runGitCommand(_branch rev-parse --abbrev-ref --symbolic-full-name "@{u}")
  set(${outputBranch} "${_branch}" PARENT_SCOPE)
endfunction()

# @brief Checks if the Git working tree is dirty (has uncommitted changes).
# @param[out] outputDirty The variable to store the result (TRUE if dirty, FALSE otherwise).
function(gpbt_isGitWorkingTreeDirty outputDirty)
  gpbt_runGitCommand(_status status --porcelain)
  if(NOT "${_status}" STREQUAL "")
    set(${outputDirty} TRUE PARENT_SCOPE)
  else()
    set(${outputDirty} FALSE PARENT_SCOPE)
  endif()
endfunction()

# @brief Checks if the current directory is inside a Git repository.
# @param[out] outputIsRepo The variable to store the result (TRUE if inside a Git repository, FALSE otherwise).
function(gpbt_isGitRepository outputIsRepo)
  gpbt_runGitCommand(_is_repo rev-parse --is-inside-work-tree)
  if("${_is_repo}" STREQUAL "true")
    set(${outputIsRepo} TRUE PARENT_SCOPE)
  else()
    set(${outputIsRepo} FALSE PARENT_SCOPE)
  endif()
endfunction()

# @brief Retrieves the Git describe string for the current commit.
# @param[out] outputDescribe The variable to store the Git describe string.
function(gpbt_getGitDescribe outputDescribe)
  gpbt_runGitCommand(_describe describe --tags --abbrev=0)
  set(${outputDescribe} "${_describe}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the latest Git tag in the repository.
# @param[out] outputTag The variable to store the latest Git tag.
function(gpbt_getGitLatestTag outputTag)
  gpbt_runGitCommand(_tag describe --tags --abbrev=0)
  set(${outputTag} "${_tag}" PARENT_SCOPE)
endfunction()

# @brief Retrieves the root directory of the Git repository.
# @param[out] outputRoot The variable to store the root directory of the Git repository.
function(gpbt_getGitRepoRoot outputRoot)
  gpbt_runGitCommand(_root rev-parse --show-toplevel)
  set(${outputRoot} "${_root}" PARENT_SCOPE)
endfunction()

# @brief Updates Git submodules in the repository.
# @param[in] forceUpdate If TRUE, forces the update of submodules even if they are already initialized.
function(gpbt_updateGitSubmodules forceUpdate)
  if(forceUpdate)
    gpbt_runGitCommand(_update submodule update --init --recursive --force)
  else()
    gpbt_runGitCommand(_update submodule update --init --recursive)
  endif()
endfunction()
