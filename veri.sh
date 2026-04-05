#!/bin/bash

# Exporting the latest g++ compiler
export CXX=g++-14
export CC=gcc-14

# Flags to be passed to the c++ compiler used by verilator
COMPILER=verilator
FLAGS=" -std=c++23"
VERILATOR_FLAGS=" --Wno-WIDTHTRUNC --Wno-MULTIDRIVEN "
TARGET_DIR="obj_dir"

# Parsing the parameters passed.

# Usage function
function usage() {
  echo "Usage:"
  echo "Help:                       $0 help|h"
  echo "Generate verible.filelist:  $0 verible"
  echo "Generate Headers:           $0 gen   src1.sv src2.sv top.sv"
  echo "Build with Testbench:       $0 build src1.sv src2.sv top.sv tb.cpp"
  echo "Clean Output Files.         $0 clean"
  echo "Run .tcl Script.            $0 tcl sample.tcl"
  exit 1
}

function runTCL() {
  set -x
  vivado -mode batch -source $TCL_SCRIPT
}

function createVeribleList() {
  find . -type f -name "*.sv" >verible.filelist
  echo "[INFO]: Systemverilog files are saved to verible.filelist."
}

# Creates .h and .cpp files
function generateHeaders() {
  $COMPILER $VERILATOR_FLAGS --cc $ALL_MODULES --top-module $BASE_NAME &&
    echo "[SUCCESS]: Headers generated successfully."
}

# WARN: It attempts to generate vaweforms by default.
function buildTestbenchExecutable() {
  $COMPILER $VERILATOR_FLAGS --cc $ALL_MODULES --top-module $BASE_NAME --exe $TEST_BENCH_CC -Mdir $TARGET_DIR --trace &&
    make -C $TARGET_DIR -f $TOP_LEVEL_MAKE CXX="$CXX" CXXFLAGS+="$FLAGS" &&
    echo "[SUCCESS]: Top level module ${TOP_LEVEL_MODULE} and test bench ${TEST_BENCH_CC} compiled successfully." &&
    echo "[SUCCESS]: Executable ${TARGET_DIR}/${EXE} emitted."
}

function parseArguments() {
  args=("$@")

  NUM_PARAMETERS=$#
  OPTION="${args[0]}"

  if [[ $OPTION == gen ]] || [[ $OPTION == build ]]; then
    TEST_BENCH_CC="${args[$NUM_PARAMETERS-1]}"
    TOP_LEVEL_MODULE=""
    ALL_MODULES=""

    if [[ $OPTION == gen ]]; then
      TOP_LEVEL_MODULE="${args[$NUM_PARAMETERS-1]}"
      ALL_MODULES="${args[@]:1}"
    elif [[ $OPTION == build ]]; then
      TOP_LEVEL_MODULE="${args[$NUM_PARAMETERS-2]}"
      ALL_MODULES=("${args[@]:1:${#args[@]}-2}")
    fi

    # Generating file names to be emitted.
    BASE_PATH=$(basename $TOP_LEVEL_MODULE)
    BASE_NAME="${BASE_PATH%.*}"
    EXE="V${BASE_NAME}"
    TOP_LEVEL_MAKE="${EXE}.mk"

  elif [[ $OPTION == tcl ]]; then
    TCL_SCRIPT="${args[1]}"
  fi
}

# Main function
function main() {
  parseArguments "$@"

  case "$OPTION" in
  gen)
    [[ $# < 1 ]] && usage

    generateHeaders
    ;;
  build)
    [[ $# < 2 ]] && usage

    buildTestbenchExecutable
    ;;
  clean)

    rm -rf obj_dir *.vcd
    ;;
  help | h)

    usage
    ;;
  verible)

    createVeribleList
    ;;
  tcl)
    runTCL
    ;;
  *)
    echo "Unknown Option."
    usage
    ;;
  esac
}

# Passing all parameters to the main function as is.
main "$@"
