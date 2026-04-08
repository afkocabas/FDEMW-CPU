import fdemw_pkg::*;
import riscv32i_pkg::*;
import pipeline_reg_pkg::*;

module fdemw_top (
    input logic clk_i,
    input logic res_i,


    input logic stall_i,

    output seg_t seg_o,
    output logic [3:0] an_o
);

  // Internal signals (wires of other modules)
  inst_kind_e dec_inst_kind;

  if_id_reg_t if_id_reg;
  imem_if imem_iff ();

  // Internal signals
  logic [3:0] an_o_c;
  seg_t seg_o_c;

  always_comb begin : assign_comb
    an_o_c = 4'b1110;
  end

  always_comb begin : seg_comb
    unique case (dec_inst_kind)
      R_T: seg_o_c = 7'b0001000;
      I_T: seg_o_c = 7'b1001111;
      S_T: seg_o_c = 7'b0010010;
      B_T: seg_o_c = 7'b0000000;
      U_T: seg_o_c = 7'b1000001;
      J_T: seg_o_c = 7'b1100001;
      INVALID_T: seg_o_c = 7'b0111111;
      default: seg_o_c = 7'b0111111;
    endcase
  end


  fetch fetch_core (
      .clk_i(clk_i),
      .res_i(res_i),

      .imem_if(imem_iff.fetch),
      .if_id_o(if_id_reg),
      .stall_i(stall_i)
  );

  decode decode_core (
      .clk_i(clk_i),
      .res_i(res_i),

      .if_id_reg_i(if_id_reg),
      .inst_kind_o(dec_inst_kind)
  );

  inst_mem i_mem (
      .clk_i(clk_i),

      .fetch_if(imem_iff.imem)
  );

  assign an_o  = an_o_c;
  assign seg_o = seg_o_c;
endmodule
