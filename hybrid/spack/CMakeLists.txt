cmake_minimum_required(VERSION 3.10)

# make sure that the default is a RELEASE
if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build, options are: None Debug Release."
      FORCE)
endif (NOT CMAKE_BUILD_TYPE)


enable_language(Fortran)

find_package(MPI REQUIRED)

#SET(ENV{FC} ${MPI_Fortran_COMPILER})
set (CMAKE_Fortran_COMPILER ${MPI_Fortran_COMPILER})
set (CMAKE_LINKER ${MPI_Fortran_COMPILER})

set (CMAKE_Fortran_FLAGS_RELEASE "-fopenmp -O3")
set (CMAKE_Fortran_FLAGS_DEBUG   "-fopenmp -g")

# set the project name
project(fhostone VERSION 1.0)

# add the executable
add_executable(fhostone fhostone.f90)

# Set default install path t o build
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}" CACHE PATH "default install path" FORCE )
endif()

install(TARGETS fhostone DESTINATION bin)

#install(FILES  ${CMAKE_CURRENT_BINARY_DIR}/fhostone DESTINATION ~/bin)


