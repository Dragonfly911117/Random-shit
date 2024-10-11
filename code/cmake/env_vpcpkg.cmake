# This CMake script sets up vcpkg for the project
# It follows a specific order of checks and actions to configure vcpkg

# Main steps:
# 1. Check for existing CMAKE_TOOLCHAIN_FILE
#    If found and valid, use it and skip to step 5
# 2. Check for VCPKG_ROOT environment variable
#    If found, use it to set CMAKE_TOOLCHAIN_FILE and skip to step 5
# 3. Attempt to install vcpkg if not found
# 4. Set up CMAKE_TOOLCHAIN_FILE using the installed vcpkg
# 5. Check for vcpkg.json in CMAKE_SOURCE_DIR and install dependencies

# Dependencies:
# - Git (for cloning vcpkg repository if needed)
# - C++ compiler (implicitly required for vcpkg bootstrap)

# Required files:
# - vcpkg.json must exist in CMAKE_SOURCE_DIR

# Variables set after including this script:
# - CMAKE_TOOLCHAIN_FILE: Path to the vcpkg toolchain file
# - VCPKG_ROOT: Path to the vcpkg installation directory
# - CMAKE_PREFIX_PATH: Appended with the path to vcpkg_installed directory

# Note: Actual package dependencies are determined by the contents of vcpkg.json
# The script will fail if vcpkg.json is not found in CMAKE_SOURCE_DIR

if(DEFINED CMAKE_TOOLCHAIN_FILE AND EXISTS "${CMAKE_TOOLCHAIN_FILE}")
    message(STATUS "Using provided CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")
else()
    if(DEFINED ENV{VCPKG_ROOT})
        set(VCPKG_ROOT $ENV{VCPKG_ROOT})
        set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
        if(EXISTS "${CMAKE_TOOLCHAIN_FILE}")
            message(STATUS "Using VCPKG toolchain from VCPKG_ROOT: ${CMAKE_TOOLCHAIN_FILE}")
        else()
            message(FATAL_ERROR "VCPKG toolchain not found at: ${CMAKE_TOOLCHAIN_FILE}")
        endif()
    else()
        message(STATUS "VCPKG_ROOT not set, attempting to install vcpkg...")
        set(VCPKG_ROOT "${CMAKE_SOURCE_DIR}/vcpkg")
        if(EXISTS "${VCPKG_ROOT}")
            message(STATUS "Vcpkg is already cloned at: ${VCPKG_ROOT}")
        else()
            execute_process(
                COMMAND git clone https://github.com/microsoft/vcpkg.git ${VCPKG_ROOT}
                RESULT_VARIABLE GIT_CLONE_RESULT
            )
            if(NOT GIT_CLONE_RESULT EQUAL 0)
                message(FATAL_ERROR "Failed to clone vcpkg repository.")
            endif()
        endif()
        if(WIN32)
            set(BOOTSTRAP_SCRIPT "${VCPKG_ROOT}/bootstrap-vcpkg.bat")
        else()
            set(BOOTSTRAP_SCRIPT "${VCPKG_ROOT}/bootstrap-vcpkg.sh")
        endif()
        if(NOT EXISTS "${VCPKG_ROOT}/vcpkg")
            execute_process(
                COMMAND ${BOOTSTRAP_SCRIPT}
                WORKING_DIRECTORY ${VCPKG_ROOT}
                RESULT_VARIABLE VCPKG_BOOTSTRAP_RESULT
            )
            if(NOT VCPKG_BOOTSTRAP_RESULT EQUAL 0)
                message(FATAL_ERROR "Vcpkg bootstrap failed.")
            endif()
        endif()
        set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
        message(STATUS "Vcpkg successfully installed at: ${VCPKG_ROOT}")
    endif()
endif()
if(EXISTS "${CMAKE_SOURCE_DIR}/vcpkg.json")
    message(STATUS "Found vcpkg.json in the source directory. Installing dependencies...")
    execute_process(
        COMMAND ${VCPKG_ROOT}/vcpkg install
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE VCPKG_INSTALL_RESULT
    )
    if(NOT VCPKG_INSTALL_RESULT EQUAL 0)
        message(FATAL_ERROR "Vcpkg install failed: ${VCPKG_INSTALL_RESULT}")
    else()
        list(APPEND CMAKE_PREFIX_PATH ${CMAKE_SOURCE_DIR}/vcpkg_installed)
    endif()
else()
    message(FATAL_ERROR "vcpkg.json not found in the source directory: ${CMAKE_SOURCE_DIR}")
endif()
