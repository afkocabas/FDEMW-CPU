import fdemw_pkg::*;
import riscv32i_pkg::*;

/*
*
  WARN: Oversimplified data memory interface.
  It even only allows to load/store word for now.
*
*
* */

interface dmem_if;

  logic  req_valid;
  logic  resp_valid;

  addr_t data_addr;
  word_t word;

  modport lsu(input resp_valid, input word, output data_addr, output req_valid);

  modport dmem(input data_addr, input req_valid, output resp_valid, output data);

endinterface
