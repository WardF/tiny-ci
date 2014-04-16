## This file should be placed in the root directory of your project.
## Then modify the CMakeLists.txt file in the root directory of your
## project to incorporate the testing dashboard.
##
## # The following are required to submit to the CDash dashboard:
##   ENABLE_TESTING()
##   INCLUDE(CTest)

set(DART_TESTING_TIMEOUT "4800")

set(CTEST_PROJECT_NAME "netcdf-c")
set(CTEST_NIGHTLY_START_TIME "00:00:00 EST")

set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "192.168.33.10") 
set(CTEST_DROP_LOCATION "/CDash/submit.php?project=netcdf-c")
set(CTEST_DROP_SITE_CDASH TRUE)
