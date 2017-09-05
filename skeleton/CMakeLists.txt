cmake_minimum_required(VERSION 3.9)

list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules" )
include(eosio)

file(GLOB SOURCE_FILES "*.cpp")
add_contract_target(currency "${SOURCE_FILES}" "${CONTRACT_INCLUDE_PATHS}" ${CMAKE_CURRENT_BINARY_DIR})
