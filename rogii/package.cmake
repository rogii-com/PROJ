if(NOT TARGET PROJ::proj)
    add_library(
        PROJ::proj
        SHARED
        IMPORTED
    )

    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set_target_properties(
            PROJ::proj
            PROPERTIES
                IMPORTED_LOCATION
                    ${CMAKE_CURRENT_LIST_DIR}/bin/proj_9.dll
                IMPORTED_IMPLIB
                    ${CMAKE_CURRENT_LIST_DIR}/lib/proj.lib
                IMPORTED_LOCATION_DEBUG
                    ${CMAKE_CURRENT_LIST_DIR}/bin/proj_9_d.dll
                IMPORTED_IMPLIB_DEBUG
                    ${CMAKE_CURRENT_LIST_DIR}/lib/proj_d.lib
                INTERFACE_INCLUDE_DIRECTORIES
                    ${CMAKE_CURRENT_LIST_DIR}/include
        )
    else()
        set_target_properties(
            PROJ::proj
            PROPERTIES
                IMPORTED_LOCATION
                    ${CMAKE_CURRENT_LIST_DIR}/lib/libproj.so.25.9.6.2
                IMPORTED_LOCATION_DEBUG
                    ${CMAKE_CURRENT_LIST_DIR}/lib/libproj_d.so.25.9.6.2
                INTERFACE_INCLUDE_DIRECTORIES
                    ${CMAKE_CURRENT_LIST_DIR}/include
        )
    endif()
endif()

# Install convenience: drop runtime and library into root of package when this
# package.cmake is consumed by CNPM installer. Keep component names generic.
set(
    COMPONENT_NAMES

    CNPM_RUNTIME_proj
    CNPM_RUNTIME
)

foreach(COMPONENT_NAME ${COMPONENT_NAMES})
    install(
        FILES
            $<TARGET_FILE:PROJ::proj>
        DESTINATION
            .
        COMPONENT
            ${COMPONENT_NAME}
        EXCLUDE_FROM_ALL
    )

    # Also place PROJ data files next to the runtime for simpler app deployment
    set(_PROJ_SHARE_DIR "${CMAKE_CURRENT_LIST_DIR}/share/proj")
    install(
        FILES
            "${_PROJ_SHARE_DIR}/proj.db"
            "${_PROJ_SHARE_DIR}/proj.ini"
        DESTINATION
            .
        COMPONENT
            ${COMPONENT_NAME}
        EXCLUDE_FROM_ALL
    )

endforeach()

