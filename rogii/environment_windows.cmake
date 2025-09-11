include(${CMAKE_CURRENT_LIST_DIR}/msvs_package.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/windowssdk_package.cmake)

CNPM_ADD_PACKAGE(
    NAME
        sqlite
    VERSION
        3.50.4
    BUILD_NUMBER
        1
    TAG
        "brdev-rogii-v3.50.4-re6074c"
)
