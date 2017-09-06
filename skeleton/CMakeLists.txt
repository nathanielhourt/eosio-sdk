cmake_minimum_required(VERSION 3.9)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")
include(eosio)

set(SOURCE_FILES "currency.cpp")
set(TEST_SOURCES "tests.cpp")
add_contract_target(currency "${SOURCE_FILES}" "${TEST_SOURCES}" ${CMAKE_CURRENT_BINARY_DIR})
