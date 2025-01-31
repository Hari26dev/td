## - Adds

#
 a compiler flag if it is supported by the compiler
#
# This function checks that the supplied compiler flag is supported and then
# adds it to the corresponding compiler flags
#
#  add_cxx_compiler_flag(<FLAG> [<VARIANT>])
#
# - Example
#
# include(AddCXXCompilerFlag)
# add_cxx_compiler_flag(-Wall)
# add_cxx_compiler_flag(-no-strict-aliasing RELEASE)
# Requires CMake 2.6+

if (__add_cxx_compiler_flag)
  return()
endif()
set(__add_cxx_compiler_flag INCLUDED)

include(CheckCXXCompilerFlag)

function(mangle_compiler_flag FLAG OUTPUT)
  string(TOUPPER "HAVE_CXX_FLAG_${FLAG}" SANITIZED_FLAG)
  string(REPLACE "+" "X" SANITIZED_FLAG ${SANITIZED_FLAG})
  string(REGEX REPLACE "[^A-Za-z_0-9]" "_" SANITIZED_FLAG ${SANITIZED_FLAG})
  string(REGEX REPLACE "_+" "_" SANITIZED_FLAG ${SANITIZED_FLAG})
  set(${OUTPUT} "${SANITIZED_FLAG}" PARENT_SCOPE)
endfunction(mangle_compiler_flag)

function(add_cxx_compiler_flag FLAG)
  string(REPLACE "-Wno-" "-W" MAIN_FLAG ${FLAG})
  mangle_compiler_flag("${MAIN_FLAG}" MANGLED_FLAG_NAME)
  if (DEFINED CMAKE_REQUIRED_FLAGS)
    set(OLD_CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} ${FLAG}")
  else()
    set(CMAKE_REQUIRED_FLAGS "${FLAG}")
  endif()
  check_cxx_compiler_flag("${MAIN_FLAG}" ${MANGLED_FLAG_NAME})
  if (DEFINED OLD_CMAKE_REQUIRED_FLAGS)
    set(CMAKE_REQUIRED_FLAGS "${OLD_CMAKE_REQUIRED_FLAGS}")
  else()
    unset(CMAKE_REQUIRED_FLAGS)
  endif()
  if (${MANGLED_FLAG_NAME})
    set(VARIANT ${ARGV1})
    if (ARGV1)
      string(TOUPPER "_${VARIANT}" VARIANT)
    endif()
    set(CMAKE_CXX_FLAGS${VARIANT} "${CMAKE_CXX_FLAGS${VARIANT}} ${FLAG}" PARENT_SCOPE)
  endif()
endfunction()

function(add_required_cxx_compiler_flag FLAG)
  string(REPLACE "-Wno-" "-W" MAIN_FLAG ${FLAG})
  mangle_compiler_flag("${MAIN_FLAG}" MANGLED_FLAG_NAME)
  set(OLD_CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")
  set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} ${FLAG}")
  check_cxx_compiler_flag("${MAIN_FLAG}" ${MANGLED_FLAG_NAME})
  set(CMAKE_REQUIRED_FLAGS "${OLD_CMAKE_REQUIRED_FLAGS}")
  if (${MANGLED_FLAG_NAME})
    set(VARIANT ${ARGV1})
    if (ARGV1)
      string(TOUPPER "_${VARIANT}" VARIANT)
    endif()
    set(CMAKE_CXX_FLAGS${VARIANT} "${CMAKE_CXX_FLAGS${VARIANT}} ${FLAG}" PARENT_SCOPE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${FLAG}" PARENT_SCOPE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${FLAG}" PARENT_SCOPE)
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${FLAG}" PARENT_SCOPE)
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} ${FLAG}" PARENT_SCOPE)
  else()
    message(FATAL_ERROR "Required flag '${FLAG}' is not supported by the compiler")
  endif()
endfunction()
