import fdemw_pkg::*;
import riscv32i_pkg::*;

interface imem_if;

  logic  req_valid;
  logic  resp_valid;

  addr_t inst_addr;
  inst_t inst;

  modport fetch(input resp_valid, input inst, output inst_addr, output req_valid);

  modport imem(input inst_addr, input req_valid, output resp_valid, output inst);

endinterface
