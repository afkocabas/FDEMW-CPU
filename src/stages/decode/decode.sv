import riscv32i_pkg::*;

module decode (
    input logic clk_i,
    input logic res_i,

    input inst_t inst_i,

    output inst_kind_e inst_kind_o

);

  inst_kind_e inst_kind_o_c;

  always_comb begin : comb_block
    inst_kind_o_c = get_inst_kind(inst_i);
  end

  assign inst_kind_o = inst_kind_o_c;

endmodule
