find_package(Python3 REQUIRED)

set(MARP_CLI_EXECUTABLE "" CACHE FILEPATH "Path to Marp executable.")

if(NOT MARP_CLI_EXECUTABLE)
  include(FetchContent)

  set(MARP_CLI_VERSION 1.5.0)
  set(MARP_CLI_URL "https://github.com/marp-team/marp-cli/releases/download/v${MARP_CLI_VERSION}/marp-cli-v${MARP_CLI_VERSION}-linux.tar.gz")

  FetchContent_Declare(download_marp-cli
    URL "${MARP_CLI_URL}"
  )
  FetchContent_MakeAvailable(download_marp-cli)
  set(MARP_CLI_EXECUTABLE "${download_marp-cli_SOURCE_DIR}/marp")
endif()

execute_process(COMMAND ${MARP_CLI_EXECUTABLE} --version 
                RESULT_VARIABLE HELP_EXIT_STATUS
                OUTPUT_QUIET
                ERROR_QUIET)

if(NOT HELP_EXIT_STATUS EQUAL 0)
  message(FATAL_ERROR "MARP_CLI_EXECUTABLE=\"${MARP_CLI_EXECUTABLE}\" is not executable")
endif()

message(STATUS "Using MARP_CLI_EXECUTABLE=\"${MARP_CLI_EXECUTABLE}\"")

function(svg2png INPUT OUTPUT)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${OUTPUT}
                     COMMAND inkscape -z -e ${CMAKE_CURRENT_BINARY_DIR}/${OUTPUT} ${CMAKE_CURRENT_SOURCE_DIR}/${INPUT} 
                     MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${INPUT}
                     COMMENT "Converting ${INPUT} to ${OUTPUT}")
endfunction()

function(marp_slides MARP_OUTPUT ARGS)
  cmake_parse_arguments(PARSE_ARGV 1 MARP "" "INPUT;TARGET" "DEPENDS")
  set(PYTHON_SCRIPTS_LOCATION ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/marp_python)

  # first pass the python templating script
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.md
                     COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/${MARP_INPUT} | ${Python3_EXECUTABLE} ${PYTHON_SCRIPTS_LOCATION}/python.py > ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.md
                     MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${MARP_INPUT}
                     DEPENDS ${MARP_DEPENDS} ${PYTHON_SCRIPTS_LOCATION}/python.py
                     COMMENT "Running scripts for ${MARP_INPUT}")

  # then generate the pdf with marp
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.pdf
                     COMMAND ${MARP_CLI_EXECUTABLE} --allow-local-files --pdf ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.md --output ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.pdf
                     MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.md
                     COMMENT "Generating slides for ${MARP_INPUT} at ${MARP_OUTPUT}")

  add_custom_target(${MARP_OUTPUT} ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.pdf)
  set_target_properties(${MARP_OUTPUT} PROPERTIES OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/${MARP_OUTPUT}.pdf)
endfunction()
