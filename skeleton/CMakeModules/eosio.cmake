set(EOSIO_SDK_PATH "$ENV{EOSIO_SDK_PATH}" CACHE PATH "Path to Eosio SDK")

if (EXISTS "${EOSIO_SDK_PATH}/bin/eoscpp")
    MESSAGE(STATUS "Found Eosio SDK: ${EOSIO_SDK_PATH}")
elseif (EXISTS "/opt/eosiosdk/bin/eoscpp")
    MESSAGE(STATUS "Found Eosio SDK: /opt/eosiosdk")
    set (EOSIO_SDK_PATH "/opt/eosiosdk")
endif()

macro(add_contract_target target SOURCE_FILES TEST_SOURCE_FILES ABI_FILE DESTINATION_FOLDER)

   if (NOT IS_ABSOLUTE "${ABI_FILE}")
      set (ABI_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${ABI_FILE}")
   else()
      set (ABI_PATH "${ABI_FILE}")
   endif()
   message(STATUS "ABI Path: ${ABI_PATH}")

  get_filename_component(wastname ${target} NAME_WE)
  set(outtarget "${DESTINATION_FOLDER}/${wastname}.wast")

  add_custom_command(OUTPUT ${outtarget}
    DEPENDS ${SOURCE_FILES}
    COMMAND ${EOSIO_SDK_PATH}/bin/eoscpp ${outtarget} ${SOURCE_FILES}
    COMMENT "Generating WAST ${wastname}.wast"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    VERBATIM
  )
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${outtarget})

  if (EXISTS "${ABI_PATH}")
    add_custom_command(OUTPUT ${outtarget}.hpp
      DEPENDS ${outtarget} ${ABI_PATH}
      COMMAND echo "const char* ${target}_wast = R\"=====("  > ${outtarget}.hpp
      COMMAND cat ${outtarget} >> ${outtarget}.hpp
      COMMAND echo ")=====\";"  >> ${outtarget}.hpp
      COMMAND echo "const char* ${target}_abi = R\"=====("  >> ${outtarget}.hpp
      COMMAND cat ${ABI_PATH} >> ${outtarget}.hpp
      COMMAND echo ")=====\";"  >> ${outtarget}.hpp
      COMMENT "Generating ${target}.wast.hpp with ABI at ${ABI_PATH}"
      VERBATIM
    )
  else (EXISTS "${ABI_PATH}")
    add_custom_command(OUTPUT ${outtarget}.hpp
      DEPENDS ${outtarget}
      COMMAND echo "const char* ${target}_wast = R\"=====("  > ${outtarget}.hpp
      COMMAND cat ${outtarget} >> ${outtarget}.hpp
      COMMAND echo ")=====\";"  >> ${outtarget}.hpp
      COMMAND echo "const char* ${target}_abi = \"\";"  >> ${outtarget}.hpp
      COMMENT "Generating ${target}.wast.hpp with empty ABI"
      VERBATIM
    )
  endif()
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${outtarget}.hpp)

  set(BOOST_COMPONENTS)
  list(APPEND BOOST_COMPONENTS thread
                               date_time
                               system
                               filesystem
                               program_options
                               signals
                               serialization
                               chrono
                               unit_test_framework
                               context
                               locale)
  find_package(Boost 1.64 REQUIRED COMPONENTS ${BOOST_COMPONENTS})
  find_package(Threads REQUIRED)
  find_package(LLVM 4.0 REQUIRED CONFIG)

  llvm_map_components_to_libnames(LLVM_LIBS support core passes mcjit native DebugInfoDWARF)

  include_directories(${EOSIO_SDK_PATH}/include ${CMAKE_CURRENT_BINARY_DIR})
  link_directories(${EOSIO_SDK_PATH}/lib)
  add_executable(contract_test EXCLUDE_FROM_ALL
                  ${TEST_SOURCE_FILES}
                  ${outtarget}.hpp
                  ${CMAKE_CURRENT_SOURCE_DIR}/testing/database_fixture.cpp
                  ${CMAKE_CURRENT_SOURCE_DIR}/testing/main.cpp)
  target_link_libraries(contract_test
                           eos_native_contract eos_chain eos_types chainbase eos_utilities eos_egenesis_none eos_wallet
                           fc
                           ${Boost_LIBRARIES}
                           Threads::Threads
                           WAST WASM Runtime Logging IR Platform
                           ${LLVM_LIBS}
                           dl
                           ssl crypto
                           secp256k1)
  set_target_properties(contract_test PROPERTIES LINKER_LANGUAGE CXX)

  add_custom_target(${target} ALL DEPENDS ${outtarget})
  add_custom_target(runtest contract_test)

endmacro(add_contract_target)
