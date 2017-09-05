set(EOSIO_SDK_PATH "$ENV{EOSIO_SDK_PATH}" CACHE PATH "Path to Eosio SDK")

if (EXISTS "${EOSIO_SDK_PATH}/bin/eoscpp")
    MESSAGE(STATUS "Found Eosio SDK: ${EOSIO_SDK_PATH}")
elseif (EXISTS "/opt/eosiosdk/bin/eoscpp")
    MESSAGE(STATUS "Found Eosio SDK: /opt/eosiosdk")
    set (EOSIO_SDK_PATH "/opt/eosiosdk")
endif()

macro(add_contract_target target SOURCE_FILES INCLUDE_FOLDERS DESTINATION_FOLDER)

  get_filename_component(wastname ${target} NAME_WE)
  set(outtarget "${DESTINATION_FOLDER}/${wastname}.wast")

  add_custom_command(OUTPUT ${outtarget}
    DEPENDS ${SOURCE_FILES}
    COMMAND ${EOSIO_SDK_PATH}/bin/eoscpp ${outtarget} ${SOURCE_FILES}
    COMMENT "Generating WAST ${wastname}.wast"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    VERBATIM
  )
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${outtarget})

  add_custom_command(OUTPUT ${outtarget}.hpp
    DEPENDS ${outtarget}
    COMMAND echo "const char* ${target}_wast = R\"=====("  > ${outtarget}.hpp
    COMMAND cat ${outtarget} >> ${outtarget}.hpp
    COMMAND echo ")=====\";"  >> ${outtarget}.hpp
    COMMENT "Generating ${target}.wast.hpp"
    VERBATIM
  )

  add_custom_target(${target} ALL DEPENDS ${outtarget}.hpp)
  set_property(TARGET ${target} PROPERTY INCLUDE_DIRECTORIES ${INCLUDE_FOLDERS})

endmacro(add_contract_target)
