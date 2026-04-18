import fdemw_pkg::*;
import riscv32i_pkg::*;

module hazard_unit (

    // Decode/Execute source registers
    input reg_idx_t rs1_i,
    input reg_idx_t rs2_i,

    input logic uses_rs1_i,
    input logic uses_rs2_i,

    // Execute and memory destination registers
    input reg_idx_t exe_rd_i,
    input reg_idx_t mem_rd_i,

    input logic exe_write_reg_i,
    input logic mem_write_reg_i,

    output forward_sel_t forward_sel_a_o,
    output forward_sel_t forward_sel_b_o
);

  always_comb begin
    forward_sel_a_o = NO_FORWARD;
    forward_sel_b_o = NO_FORWARD;

    if (uses_rs1_i && (rs1_i != '0) && exe_write_reg_i && (rs1_i == exe_rd_i))
      forward_sel_a_o = FORWARD_FROM_EXE;
    else if (uses_rs1_i && (rs1_i != '0) && mem_write_reg_i && (rs1_i == mem_rd_i))
      forward_sel_a_o = FORWARD_FROM_MEM;

    if (uses_rs2_i && (rs2_i != '0) && exe_write_reg_i && (rs2_i == exe_rd_i))
      forward_sel_b_o = FORWARD_FROM_EXE;
    else if (uses_rs2_i && (rs2_i != '0) && mem_write_reg_i && (rs2_i == mem_rd_i))
      forward_sel_b_o = FORWARD_FROM_MEM;
  end

endmodule
