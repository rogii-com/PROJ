if(
    NOT DEFINED ROOT
    OR NOT DEFINED ARCH
)
    message(
        FATAL_ERROR
        "Assert: ROOT = ${ROOT}; ARCH = ${ARCH}"
    )
endif()

set(
    PROJECT_ROOT_PATH
    "${CMAKE_CURRENT_LIST_DIR}/.."
)

set(
    ROGII_FOLDER_PATH
    "${CMAKE_CURRENT_LIST_DIR}"
)

if(NOT DEFINED GIT_COMMIT)
    set(
        GIT_COMMIT
        000000
    )

    if(DEFINED ENV{GIT_COMMIT})
        set(
            GIT_COMMIT
            $ENV{GIT_COMMIT}
        )
    else()
        find_package(Git)
        if(Git_FOUND)
            execute_process(
                COMMAND
                    ${GIT_EXECUTABLE} rev-parse --short HEAD
                OUTPUT_VARIABLE
                    GIT_COMMIT
                OUTPUT_STRIP_TRAILING_WHITESPACE
                WORKING_DIRECTORY
                    ${PROJECT_ROOT_PATH}
            )
        endif()
    endif()
endif()

set(
    TAG
    ""
)

if(DEFINED ENV{TAG})
    set(
        TAG
        "$ENV{TAG}"
    )
else()
    set(
        TAG
        "_${GIT_COMMIT}"
    )
endif()

# Detect PROJ version from root CMakeLists.txt
file(
    READ
    "${PROJECT_ROOT_PATH}/CMakeLists.txt"
    _ROOT_CMAKELISTS_CONTENT
)

set(
    VERSION_MAJOR
    0
)
set(
    VERSION_MINOR
    0
)
set(
    VERSION_PATCH
    0
)

# Extract the line with proj_version(...)
string(
    REGEX MATCH
    "proj_version\([^)\n]*\)"
    _PROJ_VERSION_LINE
    "${_ROOT_CMAKELISTS_CONTENT}"
)

if(_PROJ_VERSION_LINE)
    # Extract individual numbers
    string(
        REGEX MATCH
        "MAJOR[ \t]+([0-9]+)"
        _PROJ_VERSION_MAJOR_MATCH
        "${_PROJ_VERSION_LINE}"
    )
    if(_PROJ_VERSION_MAJOR_MATCH)
        set(
            VERSION_MAJOR
            ${CMAKE_MATCH_1}
        )
    endif()

    string(
        REGEX MATCH
        "MINOR[ \t]+([0-9]+)"
        _PROJ_VERSION_MINOR_MATCH
        "${_PROJ_VERSION_LINE}"
    )
    if(_PROJ_VERSION_MINOR_MATCH)
        set(
            VERSION_MINOR
            ${CMAKE_MATCH_1}
        )
    endif()

    string(
        REGEX MATCH
        "PATCH[ \t]+([0-9]+)"
        _PROJ_VERSION_PATCH_MATCH
        "${_PROJ_VERSION_LINE}"
    )
    if(_PROJ_VERSION_PATCH_MATCH)
        set(
            VERSION_PATCH
            ${CMAKE_MATCH_1}
        )
    endif()
endif()

if(NOT DEFINED BUILD_NUMBER)
    if(DEFINED ENV{BUILD_NUMBER})
        set(
            BUILD_NUMBER
            $ENV{BUILD_NUMBER}
        )
    else()
        set(
            BUILD_NUMBER
            0
        )
    endif()
endif()

set(
    PACKAGE_NAME
    "proj-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}-${ARCH}-${BUILD_NUMBER}${TAG}"
)

set(
    DEBUG_PATH
    "${PROJECT_ROOT_PATH}/build/debug_${ARCH}"
)

file(
    MAKE_DIRECTORY
    "${DEBUG_PATH}"
)

set(
    CMAKE_INSTALL_PREFIX
    ${ROOT}/${PACKAGE_NAME}
)

set(
    GENERATOR
    -G "Ninja"
)

# Attention: TIFF is intentionally disabled because we do not need to download data from external sources.
set(
    ENABLE_TIFF_VALUE
    OFF
)

set(
    ENABLE_CURL_VALUE
    OFF
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" ${GENERATOR} -DGIT_COMMIT=${GIT_COMMIT} -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DENABLE_TIFF=${ENABLE_TIFF_VALUE} -DENABLE_CURL=${ENABLE_CURL_VALUE} -DBUILD_PROJSYNC=OFF ${PROJECT_ROOT_PATH}
    WORKING_DIRECTORY
        "${DEBUG_PATH}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" --build .
    WORKING_DIRECTORY
        "${DEBUG_PATH}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" --build . --target install
    WORKING_DIRECTORY
        "${DEBUG_PATH}"
)

# Rename debug libraries to avoid overwriting by release build
# Note: On Windows, debug postfix is handled automatically by the build system
if(UNIX AND NOT APPLE)
    # Find the real library file (not symlinks)
    file(
        GLOB PROJ_DEBUG_LIBS
        "${CMAKE_INSTALL_PREFIX}/lib/libproj.so.*"
    )
    
    # Sort to get the most specific version (e.g., libproj.so.25.9.6.2)
    list(SORT PROJ_DEBUG_LIBS)
    list(REVERSE PROJ_DEBUG_LIBS)
    
    if(PROJ_DEBUG_LIBS)
        list(GET PROJ_DEBUG_LIBS 0 REAL_LIB)
        get_filename_component(LIB_NAME ${REAL_LIB} NAME)
        string(REPLACE "libproj.so" "libproj_d.so" NEW_LIB_NAME ${LIB_NAME})
        
        # Remove old symlinks first
        file(REMOVE "${CMAKE_INSTALL_PREFIX}/lib/libproj.so")
        if(EXISTS "${CMAKE_INSTALL_PREFIX}/lib/libproj.so.25")
            file(REMOVE "${CMAKE_INSTALL_PREFIX}/lib/libproj.so.25")
        endif()
        
        # Rename the real library file
        file(
            RENAME
            ${REAL_LIB}
            "${CMAKE_INSTALL_PREFIX}/lib/${NEW_LIB_NAME}"
        )
        
        # Recreate symlinks with new names
        execute_process(
            COMMAND ln -s ${NEW_LIB_NAME} libproj_d.so.25
            WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}/lib"
        )
        execute_process(
            COMMAND ln -s libproj_d.so.25 libproj_d.so
            WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}/lib"
        )
    endif()
endif()

set(
    RELEASE_PATH
    "${PROJECT_ROOT_PATH}/build/release_${ARCH}"
)

file(
    MAKE_DIRECTORY
    "${RELEASE_PATH}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" ${GENERATOR} -DGIT_COMMIT=${GIT_COMMIT} -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DENABLE_TIFF=${ENABLE_TIFF_VALUE} -DENABLE_CURL=${ENABLE_CURL_VALUE} -DBUILD_PROJSYNC=OFF ${PROJECT_ROOT_PATH}
    WORKING_DIRECTORY
        "${RELEASE_PATH}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" --build .
    WORKING_DIRECTORY
        "${RELEASE_PATH}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" --build . --target install
    WORKING_DIRECTORY
        "${RELEASE_PATH}"
)

# Ensure package metadata is included
file(
    COPY
        "${ROGII_FOLDER_PATH}/package.cmake"
    DESTINATION
        "${ROOT}/${PACKAGE_NAME}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" -E tar cf "${PACKAGE_NAME}.7z" --format=7zip -- "${PACKAGE_NAME}"
    WORKING_DIRECTORY
        "${ROOT}"
)

