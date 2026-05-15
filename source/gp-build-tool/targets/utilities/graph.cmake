# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/utilities/properties)
include(gp-build-tool/utilities/logger)

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
  string(APPEND _dot "    { rank=same; _legend_module; _legend_executable; _legend_plugin; }\n")
  string(APPEND _dot "  }\n\n")

  # Node declarations
  foreach(target IN LISTS registeredTargets)
    gpbt_pushScope("${target}")
    gpbt_getScopedProperty(_targetName     targetName)
    gpbt_getScopedProperty(_targetType     targetType)
    gpbt_getScopedProperty(_targetExportName targetExportName)
    gpbt_popScope()

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

    string(APPEND _dot "  \"${targetExportName}\" [label=\"${targetName}\", shape=${_shape}, style=filled, fillcolor=${_color}];\n")
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
