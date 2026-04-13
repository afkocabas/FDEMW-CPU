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

  logic  wr_en;
  logic  r_en;

  word_t wr_data;
  word_t r_data;

  addr_t m_addr;

  logic  req_valid;
  logic  resp_valid;

  modport core(
      input resp_valid,
      input r_data,
      output req_valid,
      output m_addr,
      output wr_en,
      output r_en,
      output wr_data
  );

  modport dmem(
      input req_valid,
      input m_addr,
      input wr_en,
      input r_en,
      input wr_data,
      output resp_valid,
      output r_data
  );

endinterface
