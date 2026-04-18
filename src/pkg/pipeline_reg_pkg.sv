package pipeline_reg_pkg;
  import fdemw_pkg::*;
  import riscv32i_pkg::*;

  typedef struct packed {
    logic  valid;
    inst_t inst;
    addr_t pc;
  } if_id_reg_t;

  typedef struct packed {
    inst_t inst;
    inst_format_e inst_format;
    imm_t imm;
    reg_idx_t rd_idx;
    reg_idx_t rs1_idx;
    reg_idx_t rs2_idx;
    alu_op_t alu_op;
    addr_t pc;
    alu_src1_t alu_src1;
    alu_src2_t alu_src2;
    wb_sel_t wb_sel;
    branch_type_t branch_type;

    logic valid;
    logic illegal_inst;
    logic uses_rs1;
    logic uses_rs2;
    logic is_reg_write;
    logic is_mem_read;
    logic is_mem_write;
    logic is_branch;
    logic is_jal;
    logic is_jalr;


    gp_reg_t rs1_data;
    gp_reg_t rs2_data;
  } id_exe_reg_t;

  typedef struct packed {
    id_exe_reg_t id_exe_reg;
    gp_reg_t alu_result;
  } exe_mem_reg_t;

  typedef struct packed {
    exe_mem_reg_t exe_mem_reg;
    word_t r_data;
  } mem_wb_reg_t;

endpackage
