include(${CMAKE_CURRENT_LIST_DIR}/msvs_package.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/windowssdk_package.cmake)

CNPM_ADD_PACKAGE(
    NAME
        sqlite
    VERSION
        3.50.4
    ARCHITECTURE
        amd64
    BUILD_NUMBER
        3
    TAG
        "lddissue"
)
