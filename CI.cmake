#####
# Some Test/System Setup
#####
set (CTEST_PROJECT_NAME "netcdf-c")


# Get Hostname
find_program(HOSTNAME_CMD NAMES hostname)
exec_program(${HOSTNAME_CMD} OUTPUT_VARIABLE HOSTNAME)
set(CTEST_SITE "${HOSTNAME}")

# Get system configuration
find_program(UNAME NAMES uname)
macro(getuname name flag)
	exec_program("${UNAME}" ARGS "${flag}" OUTPUT_VARIABLE "${name}")
endmacro(getuname)
getuname(osname -s)
getuname(osrel  -r)
getuname(cpu    -m)
set(CTEST_BUILD_NAME        "${osname}-${osrel}-${cpu}")

# Set locations of src/build
set (CTEST_DASHBOARD_ROOT "${CTEST_SCRIPT_DIRECTORY}/Dashboards")
SET (CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/netcdf-src")
SET (CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/builds/build-cont")
set(ENV{LC_ALL} C)

####
# End Test/System Setup
#####

set (CTEST_CMAKE_GENERATOR "Unix Makefiles")
FIND_PROGRAM(GITNAMES NAMES git)

set (CTEST_GIT_COMMAND ${GITNAMES})
set (CTEST_COMMAND "\"${CTEST_EXECUTABLE_NAME}\" -D Continuous")

set (CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone file:///vagrant/netcdf-c ${CTEST_SOURCE_DIRECTORY}")
set (CTEST_UPDATE_COMMAND ${CTEST_GIT_COMMAND})
set (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)

## Set CTest Options
set(OPTIONS -DENABLE_EXTRA_TESTS=ON -DENABLE_HDF4=ON -DNC_CTEST_DROP_LOC_PREFIX=/CDash -DNC_CTEST_DROP_SITE=192.168.33.10)

## Kick off the test
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY_ONCE 1)
set (first_loop 1)
ctest_start("Continuous")

while (${CTEST_ELAPSED_TIME} GREATER -1)
	set (START_TIME ${CTEST_ELAPSED_TIME})
	ctest_update(RETURN_VALUE count)
	message("Count: ${count}")
	if (count GREATER 0 OR first_loop GREATER 0)
		SET(CTEST_BUILD_NAME	"${CTEST_BUILD_NAME}-1")
		
		message("Count ${count} > 0, running analysis.")
		ctest_configure(OPTIONS "${OPTIONS}")
		message("Configuring")
		ctest_build()
		message("Building")
		ctest_test()
		message("Testing")
		ctest_submit()
		message("Submitting")
		message("Analysis complete.")
		set(first_loop 0)
	endif()
	ctest_sleep( ${START_TIME} 60 ${CTEST_ELAPSED_TIME})
endwhile()
