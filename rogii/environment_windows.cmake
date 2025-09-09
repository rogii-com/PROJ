include(${CMAKE_CURRENT_LIST_DIR}/msvs_package.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/windowssdk_package.cmake)

CNPM_ADD_PACKAGE(
    NAME
        sqlite
    VERSION
        3.50.4
    BUILD_NUMBER
        0
    TAG
        "_8ed5e7365e"
)
