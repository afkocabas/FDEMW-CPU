import riscv32i_pkg::*;
import pipeline_reg_pkg::*;

module decode (
    input logic clk_i,
    input logic res_i,

    input if_id_reg_t if_id_reg_i,

    output inst_format_e inst_kind_o

);

  inst_format_e inst_kind_o_c;

  always_comb begin : comb_block
    inst_kind_o_c = get_inst_format(if_id_reg_i.inst);
  end

  assign inst_kind_o = inst_kind_o_c;

endmodule
