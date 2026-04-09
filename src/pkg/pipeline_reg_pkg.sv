package pipeline_reg_pkg;
  import fdemw_pkg::*;
  import riscv32i_pkg::*;

  typedef struct packed {
    logic  valid;
    inst_t inst;
    addr_t pc;
  } if_id_reg_t;

  typedef struct packed {logic valid;} id_exe_reg_t;

endpackage
