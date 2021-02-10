list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

include(CMakeFindDependencyMacro)
find_dependency(Coroutines QUIET REQUIRED)
find_dependency(liburing QUIET REQUIRED)

include("${CMAKE_CURRENT_LIST_DIR}/cppcoroTargets.cmake")
