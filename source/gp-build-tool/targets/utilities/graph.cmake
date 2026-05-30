# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

# @brief Helper to determine a "smart" folder for grouping.
# It takes the first component of a path (e.g. "rhi/base" -> "rhi")
# to group related targets into higher-level categories automatically.
function(gpbt_getSmartFolder targetFolder outSmartFolder)
  if(NOT targetFolder)
    set(${outSmartFolder} "Uncategorized" PARENT_SCOPE)
    return()
  endif()

  # If it contains a slash, take the first part
  string(FIND "${targetFolder}" "/" slashIndex)
  if(NOT slashIndex EQUAL -1)
    string(SUBSTRING "${targetFolder}" 0 ${slashIndex} firstPart)
    set(${outSmartFolder} "${firstPart}" PARENT_SCOPE)
  else()
    set(${outSmartFolder} "${targetFolder}" PARENT_SCOPE)
  endif()
endfunction()

# @brief Write a Graphviz DOT file visualizing the registered target dependency graph.
#
# Node styling:
#   module     - filled box (lightblue)
#   executable - filled house shape (lightyellow)
#   plugin     - filled hexagon (lightcoral)
#
# Edge styling by visibility:
#   PUBLIC   - solid blue arrow
#   PRIVATE  - solid darkgray arrow
#   INTERNAL - solid orange arrow
#   DYNAMIC  - dashed red arrow (runtime load, not linked)
#
# Render with:  dot -Tsvg gpbt_deps.dot -o gpbt_deps.svg
#               dot -Tpng gpbt_deps.dot -o gpbt_deps.png
#
# @param[in] outputFile Absolute path where the DOT file will be written.
function(gpbt_exportDependencyGraph outputFile)
  gpbt_getProperty(GPBT_TARGETS registeredTargets)

  # Preamble
  set(_dot "digraph GPBT {\n")
  string(APPEND _dot "  rankdir=LR;\n")
  string(APPEND _dot "  splines=ortho;\n")
  string(APPEND _dot "  node [fontname=\"Helvetica\", fontsize=11];\n")
  string(APPEND _dot "  edge [fontname=\"Helvetica\", fontsize=9];\n\n")

  # Legend cluster
  string(APPEND _dot "  subgraph cluster_legend {\n")
  string(APPEND _dot "    label=\"Legend\"; style=dashed; color=gray;\n")
  string(APPEND _dot "    fontname=\"Helvetica\"; fontsize=10;\n")
  string(APPEND _dot "    _legend_module     [label=\"module\",     shape=box,      style=filled, fillcolor=lightblue];\n")
  string(APPEND _dot "    _legend_executable [label=\"executable\", shape=house,    style=filled, fillcolor=lightyellow];\n")
  string(APPEND _dot "    _legend_plugin     [label=\"plugin\",     shape=hexagon,  style=filled, fillcolor=lightcoral];\n")
  string(APPEND _dot "    _legend_test       [label=\"test\",       shape=box,      style=\"filled,dashed\", fillcolor=white];\n")
  string(APPEND _dot "    { rank=same; _legend_module; _legend_executable; _legend_plugin; _legend_test; }\n")
  string(APPEND _dot "  }\n\n")

  # Find all unique "smart" folders to group targets
  set(_folders "")
  foreach(target IN LISTS registeredTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetCustomFolder targetFolder)
    gpbt_popScope()

    gpbt_getSmartFolder("${targetFolder}" smartFolder)
    if(NOT smartFolder IN_LIST _folders)
      list(APPEND _folders "${smartFolder}")
    endif()
  endforeach()

  # Node declarations grouped by Custom Folder
  set(clusterIndex 0)
  foreach(folder IN LISTS _folders)
    if(NOT folder STREQUAL "Uncategorized")
      string(APPEND _dot "  subgraph cluster_${clusterIndex} {\n")
      string(APPEND _dot "    label=\"${folder}\"; style=dashed; color=gray;\n")
      string(APPEND _dot "    fontname=\"Helvetica\"; fontsize=10;\n")
    endif()

    foreach(target IN LISTS registeredTargets)
      gpbt_pushScope("${target}")
      gpbt_getScopedProperty(_targetCustomFolder targetCustomFolder)
      gpbt_getScopedProperty(_targetName     targetName)
      gpbt_getScopedProperty(_targetType     targetType)
      gpbt_getScopedProperty(_targetExportName targetExportName)
      gpbt_getScopedProperty(_targetEnableTests targetEnableTests)
      gpbt_getScopedProperty(_targetLocation targetLocation)
      gpbt_popScope()

      gpbt_getSmartFolder("${targetCustomFolder}" targetSmartFolder)

      if(targetSmartFolder STREQUAL folder)
        if("${targetType}" STREQUAL "executable")
          set(_shape "house")
          set(_color "lightyellow")
        elseif("${targetType}" STREQUAL "plugin")
          set(_shape "hexagon")
          set(_color "lightcoral")
        else()
          set(_shape "box")
          set(_color "lightblue")
        endif()

        set(_style "filled")
        if(targetEnableTests)
          set(_style "filled,dashed")
        endif()

        # Added tooltip and URL for hyperlinks
        string(APPEND _dot "    \"${targetExportName}\" [label=\"${targetName}\", shape=${_shape}, style=\"${_style}\", fillcolor=${_color}, tooltip=\"Type: ${targetType}\\nFolder: ${targetCustomFolder}\", URL=\"file://${targetLocation}\"];\n")
      endif()
    endforeach()

    if(NOT folder STREQUAL "Uncategorized")
      string(APPEND _dot "  }\n\n")
    endif()
    math(EXPR clusterIndex "${clusterIndex} + 1")
  endforeach()

  string(APPEND _dot "\n")

  # Edge declarations
  foreach(target IN LISTS registeredTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetExportName        fromExport)
    gpbt_getScopedProperty(_targetPublicDependencies   pubDeps)
    gpbt_getScopedProperty(_targetPrivateDependencies  privDeps)
    gpbt_getScopedProperty(_targetInternalDependencies intDeps)
    gpbt_getScopedProperty(_targetDynamicDependencies  dynDeps)
    gpbt_popScope()

    gpbt_getProperty(GPBT_TARGETS allTargets)

    foreach(dep IN LISTS pubDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _dot "  \"${fromExport}\" -> \"${toExport}\" [label=\"PUBLIC\", color=blue, fontcolor=blue];\n")
      else()
        string(APPEND _dot "  \"${fromExport}\" -> \"${dep}\" [label=\"PUBLIC (ext)\", color=blue, fontcolor=blue, style=dashed];\n")
      endif()
    endforeach()

    foreach(dep IN LISTS privDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _dot "  \"${fromExport}\" -> \"${toExport}\" [label=\"PRIVATE\", color=darkgray, fontcolor=darkgray];\n")
      else()
        string(APPEND _dot "  \"${fromExport}\" -> \"${dep}\" [label=\"PRIVATE (ext)\", color=darkgray, fontcolor=darkgray, style=dashed];\n")
      endif()
    endforeach()

    foreach(dep IN LISTS intDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _dot "  \"${fromExport}\" -> \"${toExport}\" [label=\"INTERNAL\", color=darkorange, fontcolor=darkorange];\n")
      else()
        string(APPEND _dot "  \"${fromExport}\" -> \"${dep}\" [label=\"INTERNAL (ext)\", color=darkorange, fontcolor=darkorange, style=dashed];\n")
      endif()
    endforeach()

    foreach(dep IN LISTS dynDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _dot "  \"${fromExport}\" -> \"${toExport}\" [label=\"DYNAMIC\", color=red, fontcolor=red, style=dashed];\n")
      else()
        string(APPEND _dot "  \"${fromExport}\" -> \"${dep}\" [label=\"DYNAMIC (ext)\", color=red, fontcolor=red, style=dashed];\n")
      endif()
    endforeach()
  endforeach()

  string(APPEND _dot "}\n")

  file(WRITE "${outputFile}" "${_dot}")
  gpbt_log(SUCCESS "Dependency graph written to: ${outputFile}")
  gpbt_log(BULLET "Render with: dot -Tsvg \"${outputFile}\" -o \"${outputFile}.svg\"")
endfunction()

# @brief Write a Mermaid flowchart file visualizing the registered target dependency graph.
#
# Node styling (shapes):
#   module     - [label] (square)
#   executable - [/label/] (parallelogram)
#   plugin     - {{label}} (hexagon)
#
# Node styling (colors):
#   module     - #add8e6 (lightblue)
#   executable - #ffffe0 (lightyellow)
#   plugin     - #f08080 (lightcoral)
#
# Edge styling by visibility:
#   PUBLIC   - solid blue
#   PRIVATE  - solid darkgray
#   INTERNAL - solid orange
#   DYNAMIC  - dashed red (runtime load, not linked)
#
# Render with:  mermaid-cli (mmdc) or paste into any markdown viewer with mermaid support.
#
# @param[in] outputFile Absolute path where the Mermaid file will be written.
function(gpbt_exportMermaidGraph outputFile)
  gpbt_getProperty(GPBT_TARGETS registeredTargets)

  # Preamble
  set(_mmd "flowchart LR\n")

  # Find all unique "smart" folders to group targets
  set(_folders "")
  foreach(target IN LISTS registeredTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetCustomFolder targetFolder)
    gpbt_popScope()

    gpbt_getSmartFolder("${targetFolder}" smartFolder)
    if(NOT smartFolder IN_LIST _folders)
      list(APPEND _folders "${smartFolder}")
    endif()
  endforeach()

  # Node declarations grouped by Custom Folder
  set(subgraphIndex 0)
  foreach(folder IN LISTS _folders)
    if(NOT folder STREQUAL "Uncategorized")
      string(APPEND _mmd "  subgraph cluster_${subgraphIndex} [\"${folder}\"]\n")
    endif()

    foreach(target IN LISTS registeredTargets)
      gpbt_pushScope("${target}")
      gpbt_getScopedProperty(_targetCustomFolder targetCustomFolder)
      gpbt_getScopedProperty(_targetName     targetName)
      gpbt_getScopedProperty(_targetType     targetType)
      gpbt_getScopedProperty(_targetExportName targetExportName)
      gpbt_getScopedProperty(_targetEnableTests targetEnableTests)
      gpbt_popScope()

      gpbt_getSmartFolder("${targetCustomFolder}" targetSmartFolder)

      if(targetSmartFolder STREQUAL folder)
        if("${targetType}" STREQUAL "executable")
          set(_open "[/")
          set(_close "/]")
          set(_color "#ffffe0")
        elseif("${targetType}" STREQUAL "plugin")
          set(_open "{{")
          set(_close "}}")
          set(_color "#f08080")
        else()
          set(_open "[")
          set(_close "]")
          set(_color "#add8e6")
        endif()

        # Added tooltip for Mermaid (using square brackets for label and then tooltip property if supported,
        # but Mermaid usually just uses the label. Some renderers support tooltips).
        # Standard Mermaid doesn't have a direct "tooltip" attribute like DOT, but we can use 'click' for links.
        string(APPEND _mmd "    ${targetExportName}${_open}\"${targetName}\"${_close}\n")
        string(APPEND _mmd "    style ${targetExportName} fill:${_color},stroke:#333,stroke-width:1px")
        if(targetEnableTests)
          string(APPEND _mmd ",stroke-dasharray: 5 5")
        endif()
        string(APPEND _mmd "\n")
      endif()
    endforeach()

    if(NOT folder STREQUAL "Uncategorized")
      string(APPEND _mmd "  end\n\n")
    endif()
    math(EXPR subgraphIndex "${subgraphIndex} + 1")
  endforeach()

  string(APPEND _mmd "\n")

  # Edge declarations
  set(linkIndex 0)
  foreach(target IN LISTS registeredTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetExportName        fromExport)
    gpbt_getScopedProperty(_targetPublicDependencies   pubDeps)
    gpbt_getScopedProperty(_targetPrivateDependencies  privDeps)
    gpbt_getScopedProperty(_targetInternalDependencies intDeps)
    gpbt_getScopedProperty(_targetDynamicDependencies  dynDeps)
    gpbt_popScope()

    gpbt_getProperty(GPBT_TARGETS allTargets)

    foreach(dep IN LISTS pubDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _mmd "  ${fromExport} -- \"PUBLIC\" --> ${toExport}\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#0000ff,color:#0000ff\n")
      else()
        string(APPEND _mmd "  ${fromExport} -- \"PUBLIC (ext)\" --> ${dep}[\"${dep}\"]\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#0000ff,color:#0000ff,stroke-dasharray: 5 5\n")
      endif()
      math(EXPR linkIndex "${linkIndex} + 1")
    endforeach()

    foreach(dep IN LISTS privDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _mmd "  ${fromExport} -- \"PRIVATE\" --> ${toExport}\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#a9a9a9,color:#a9a9a9\n")
      else()
        string(APPEND _mmd "  ${fromExport} -- \"PRIVATE (ext)\" --> ${dep}[\"${dep}\"]\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#a9a9a9,color:#a9a9a9,stroke-dasharray: 5 5\n")
      endif()
      math(EXPR linkIndex "${linkIndex} + 1")
    endforeach()

    foreach(dep IN LISTS intDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _mmd "  ${fromExport} -- \"INTERNAL\" --> ${toExport}\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#ffa500,color:#ffa500\n")
      else()
        string(APPEND _mmd "  ${fromExport} -- \"INTERNAL (ext)\" --> ${dep}[\"${dep}\"]\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#ffa500,color:#ffa500,stroke-dasharray: 5 5\n")
      endif()
      math(EXPR linkIndex "${linkIndex} + 1")
    endforeach()

    foreach(dep IN LISTS dynDeps)
      string(REGEX REPLACE "[^a-zA-Z0-9_]+" "_" cleanDep "${dep}")
      string(TOLOWER "${cleanDep}" cleanDep)
      if("${cleanDep}" IN_LIST allTargets)
        gpbt_pushScope("${cleanDep}")
        gpbt_getScopedProperty(_targetExportName toExport)
        gpbt_popScope()
        string(APPEND _mmd "  ${fromExport} -. \"DYNAMIC\" .-> ${toExport}\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#ff0000,color:#ff0000\n")
      else()
        string(APPEND _mmd "  ${fromExport} -. \"DYNAMIC (ext)\" .-> ${dep}[\"${dep}\"]\n")
        string(APPEND _mmd "  linkStyle ${linkIndex} stroke:#ff0000,color:#ff0000\n")
      endif()
      math(EXPR linkIndex "${linkIndex} + 1")
    endforeach()
  endforeach()

  file(WRITE "${outputFile}" "${_mmd}")
  gpbt_log(SUCCESS "Dependency graph (Mermaid) written to: ${outputFile}")
  gpbt_log(BULLET "Paste the content of \"${outputFile}\" into https://mermaid.live to visualize it.")
endfunction()
