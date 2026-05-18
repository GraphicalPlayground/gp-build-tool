# Copyright (c) - Graphical Playground. All rights reserved.
# For more information, see https://graphical-playground/legal
# mailto:support AT graphical-playground DOT com

include_guard(GLOBAL)

include(gp-build-tool/tests/asserts)
include(gp-build-tool/utilities/properties)

gpbt_startTestSection("Properties: Set and Get")
  # Test setting and getting a standard string
  gpbt_setProperty("TEST_PROP_BASIC" "Hello World")
  gpbt_getProperty("TEST_PROP_BASIC" result)
  gpbt_assertEqual("${result}" "Hello World" "Expected to retrieve the exact string that was set")

  # Test setting an empty string
  gpbt_setProperty("TEST_PROP_EMPTY" "")
  gpbt_getProperty("TEST_PROP_EMPTY" result)
  gpbt_assertEqual("${result}" "" "Expected to retrieve an empty string")

  # Test getting an unset property
  gpbt_getProperty("TEST_PROP_UNSET" result)
  gpbt_assertEqual("${result}" "" "Expected an unset property to return an empty string")
gpbt_endTestSection()

gpbt_startTestSection("Properties: Append")
  # Append to an unset property
  gpbt_appendProperty("TEST_PROP_LIST" "Item1")
  gpbt_getProperty("TEST_PROP_LIST" result)
  gpbt_assertEqual("${result}" "Item1" "Expected appending to unset property to simply set the value")

  # Append to an existing property
  gpbt_appendProperty("TEST_PROP_LIST" "Item2")
  gpbt_getProperty("TEST_PROP_LIST" result)
  gpbt_assertEqual("${result}" "Item1;Item2" "Expected appending a second item to create a semicolon-separated list")

  # Append a third item
  gpbt_appendProperty("TEST_PROP_LIST" "Item3")
  gpbt_getProperty("TEST_PROP_LIST" result)
  gpbt_assertEqual("${result}" "Item1;Item2;Item3" "Expected appending to continue adding to the list")

  # Append to an explicitly-empty property
  gpbt_setProperty("TEST_PROP_LIST_EMPTY" "")
  gpbt_appendProperty("TEST_PROP_LIST_EMPTY" "OnlyItem")
  gpbt_getProperty("TEST_PROP_LIST_EMPTY" result)
  gpbt_assertEqual("${result}" "OnlyItem" "Expected appending to an empty property to produce a single-element list")
gpbt_endTestSection()

gpbt_startTestSection("Properties: Pop")
  # Setup list for popping
  gpbt_setProperty("TEST_PROP_POP" "A;B;C")

  # Pop the last value
  gpbt_popProperty("TEST_PROP_POP" poppedVal)
  gpbt_assertEqual("${poppedVal}" "C" "Expected popped value to be 'C'")
  gpbt_getProperty("TEST_PROP_POP" result)
  gpbt_assertEqual("${result}" "A;B" "Expected property to have 'C' removed")

  # Pop the remaining values
  gpbt_popProperty("TEST_PROP_POP" poppedVal)
  gpbt_assertEqual("${poppedVal}" "B" "Expected popped value to be 'B'")

  gpbt_popProperty("TEST_PROP_POP" poppedVal)
  gpbt_assertEqual("${poppedVal}" "A" "Expected popped value to be 'A'")
  gpbt_getProperty("TEST_PROP_POP" result)
  gpbt_assertEqual("${result}" "" "Expected property list to be empty after popping all elements")

  # Pop from an empty property
  gpbt_popProperty("TEST_PROP_POP" poppedVal)
  gpbt_assertEqual("${poppedVal}" "" "Expected popping an empty property to return an empty string")

  # Pop from a completely unset property
  gpbt_popProperty("TEST_PROP_NEVER_SET" poppedVal)
  gpbt_assertEqual("${poppedVal}" "" "Expected popping an unset property to return an empty string")
gpbt_endTestSection()

gpbt_startTestSection("Properties: Increment and Decrement")
  # Increment unset property
  gpbt_incrementProperty("TEST_PROP_MATH")
  gpbt_getProperty("TEST_PROP_MATH" result)
  gpbt_assertEqual("${result}" "1" "Expected incrementing an unset property to initialize it to 1")

  # Increment existing property
  gpbt_incrementProperty("TEST_PROP_MATH")
  gpbt_getProperty("TEST_PROP_MATH" result)
  gpbt_assertEqual("${result}" "2" "Expected incrementing 1 to result in 2")

  # Decrement existing property
  gpbt_decrementProperty("TEST_PROP_MATH")
  gpbt_getProperty("TEST_PROP_MATH" result)
  gpbt_assertEqual("${result}" "1" "Expected decrementing 2 to result in 1")

  # Decrement past zero into negatives
  gpbt_decrementProperty("TEST_PROP_MATH")
  gpbt_decrementProperty("TEST_PROP_MATH")
  gpbt_getProperty("TEST_PROP_MATH" result)
  gpbt_assertEqual("${result}" "-1" "Expected decrementing below 0 to result in negative numbers")

  # Decrement unset property
  gpbt_decrementProperty("TEST_PROP_MATH_NEW")
  gpbt_getProperty("TEST_PROP_MATH_NEW" result)
  gpbt_assertEqual("${result}" "-1" "Expected decrementing an unset property to initialize it to -1")
gpbt_endTestSection()

gpbt_startTestSection("Properties: Scoped Properties")
  # No active scope initially
  gpbt_currentScope(scopeVal)
  gpbt_assertEqual("${scopeVal}" "" "Expected no active scope before any push")

  gpbt_isInScope("TargetA" inScope)
  gpbt_assertEqual("${inScope}" "FALSE" "Expected TargetA to not be in scope before any push")

  # Push first scope
  gpbt_pushScope("TargetA")
  gpbt_currentScope(scopeVal)
  gpbt_assertEqual("${scopeVal}" "TargetA" "Expected current scope to be TargetA after push")

  gpbt_isInScope("TargetA" inScope)
  gpbt_assertEqual("${inScope}" "TRUE" "Expected TargetA to be in scope after push")

  gpbt_isInScope("TargetB" inScope)
  gpbt_assertEqual("${inScope}" "FALSE" "Expected TargetB to not be in scope when only TargetA was pushed")

  # Push nested scope
  gpbt_pushScope("TargetB")
  gpbt_currentScope(scopeVal)
  gpbt_assertEqual("${scopeVal}" "TargetB" "Expected current scope to be TargetB after nested push")

  gpbt_isInScope("TargetA" inScope)
  gpbt_assertEqual("${inScope}" "TRUE" "Expected TargetA to still be in scope stack while nested")

  gpbt_isInScope("TargetB" inScope)
  gpbt_assertEqual("${inScope}" "TRUE" "Expected TargetB to be in scope after its push")

  # Pop inner scope
  gpbt_popScope()
  gpbt_currentScope(scopeVal)
  gpbt_assertEqual("${scopeVal}" "TargetA" "Expected current scope to return to TargetA after popping TargetB")

  gpbt_isInScope("TargetB" inScope)
  gpbt_assertEqual("${inScope}" "FALSE" "Expected TargetB to no longer be in scope after pop")

  gpbt_isInScope("TargetA" inScope)
  gpbt_assertEqual("${inScope}" "TRUE" "Expected TargetA to remain in scope after inner pop")

  # Pop outer scope
  gpbt_popScope()
  gpbt_currentScope(scopeVal)
  gpbt_assertEqual("${scopeVal}" "" "Expected no active scope after all scopes popped")

  gpbt_isInScope("TargetA" inScope)
  gpbt_assertEqual("${inScope}" "FALSE" "Expected TargetA to no longer be in scope after final pop")
gpbt_endTestSection()

gpbt_startTestSection("Properties: Scoped Property Set and Get")
  # No active scope, scoped get returns empty
  gpbt_getScopedProperty("FOO" result)
  gpbt_assertEqual("${result}" "" "Expected unset scoped property with no active scope to return empty")

  # Set and get within a scope
  gpbt_pushScope("ScopedPropA")
  gpbt_setScopedProperty("FOO" "hello")
  gpbt_getScopedProperty("FOO" result)
  gpbt_assertEqual("${result}" "hello" "Expected to retrieve the value set in the current scope")

  # Unset key within active scope returns empty
  gpbt_getScopedProperty("UNSET_KEY" result)
  gpbt_assertEqual("${result}" "" "Expected an unset scoped key to return empty")

  # Scoped property is isolated, not visible from a different scope
  gpbt_pushScope("ScopedPropB")
  gpbt_getScopedProperty("FOO" result)
  gpbt_assertEqual("${result}" "" "Expected FOO from ScopedPropA to not be visible in ScopedPropB")
  gpbt_popScope()

  # After popping inner scope, outer scope value is unchanged
  gpbt_getScopedProperty("FOO" result)
  gpbt_assertEqual("${result}" "hello" "Expected ScopedPropA FOO to remain after inner scope was popped")

  gpbt_popScope()

  # Property is not visible after its scope is gone
  gpbt_getScopedProperty("FOO" result)
  gpbt_assertEqual("${result}" "" "Expected scoped property to not be visible after its scope was popped")
gpbt_endTestSection()

gpbt_startTestSection("Properties: Scoped Bulk Set")
  gpbt_pushScope("BulkScope")
  gpbt_setBulkScopedProperties("K1" "V1" "K2" "V2" "K3" "V3")
  gpbt_getScopedProperty("K1" result)
  gpbt_assertEqual("${result}" "V1" "Expected bulk-set K1 to equal V1")
  gpbt_getScopedProperty("K2" result)
  gpbt_assertEqual("${result}" "V2" "Expected bulk-set K2 to equal V2")
  gpbt_getScopedProperty("K3" result)
  gpbt_assertEqual("${result}" "V3" "Expected bulk-set K3 to equal V3")
  gpbt_popScope()
gpbt_endTestSection()

gpbt_startTestSection("Properties: Scoped Bulk Set with Empty Values")
  gpbt_pushScope("BulkEmptyScope")
  gpbt_setBulkScopedProperties("K1" "" "K2" "between" "K3" "" "K4" "end")
  gpbt_getScopedProperty("K1" result)
  gpbt_assertEqual("${result}" "" "Expected K1 to be empty when set to empty string")
  gpbt_getScopedProperty("K2" result)
  gpbt_assertEqual("${result}" "between" "Expected K2 to be unaffected by adjacent empty values")
  gpbt_getScopedProperty("K3" result)
  gpbt_assertEqual("${result}" "" "Expected K3 to be empty when set to empty string")
  gpbt_getScopedProperty("K4" result)
  gpbt_assertEqual("${result}" "end" "Expected K4 to be unaffected by preceding empty value")
  gpbt_popScope()
gpbt_endTestSection()

gpbt_startTestSection("Properties: Scoped Append and Pop")
  gpbt_pushScope("ScopedListScope")

  # Append builds a list
  gpbt_appendScopedProperty("ITEMS" "X")
  gpbt_appendScopedProperty("ITEMS" "Y")
  gpbt_appendScopedProperty("ITEMS" "Z")
  gpbt_getScopedProperty("ITEMS" result)
  gpbt_assertEqual("${result}" "X;Y;Z" "Expected three appended items to form a semicolon-separated list")

  # Pop removes the last element
  gpbt_popScopedProperty("ITEMS" poppedVal)
  gpbt_assertEqual("${poppedVal}" "Z" "Expected popped value to be Z")
  gpbt_getScopedProperty("ITEMS" result)
  gpbt_assertEqual("${result}" "X;Y" "Expected list to have Z removed after pop")

  # Pop from an unset scoped property returns empty
  gpbt_popScopedProperty("NEVER_SET" poppedVal)
  gpbt_assertEqual("${poppedVal}" "" "Expected popping an unset scoped property to return empty")

  gpbt_popScope()
gpbt_endTestSection()
