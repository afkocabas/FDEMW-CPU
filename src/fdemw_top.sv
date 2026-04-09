import fdemw_pkg::*;
import riscv32i_pkg::*;
import pipeline_reg_pkg::*;

module fdemw_top (
    input logic clk_i,
    input logic res_i,


    input logic stall_i,
    input logic flush_i,

    output seg_t seg_o,
    output logic [3:0] an_o
);

  // Internal signals (wires of other modules)
  inst_kind_e dec_inst_kind;

  // Pipeline registers
  if_id_reg_t if_id_reg_q, if_id_reg_d;

  // Interfaces
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

  // ------------- Fetch --------------------
  if_id_reg_t if_id_o;

  fetch fetch_core (
      .clk_i  (clk_i),
      .res_i  (res_i),
      .stall_i(stall_i),

      .imem_if(imem_iff.fetch),

      .if_id_o(if_id_o)
  );

  decode decode_core (
      .clk_i(clk_i),
      .res_i(res_i),

      .if_id_reg_i(if_id_reg_q),
      .inst_kind_o(dec_inst_kind)
  );

  inst_mem i_mem (
      .clk_i(clk_i),

      .fetch_if(imem_iff.imem)
  );


  always_comb begin : reg_updates
    if_id_reg_d = if_id_reg_q;

    if (flush_i) begin
      if_id_reg_d = '0;
    end else if (stall_i) begin
      if_id_reg_d = if_id_reg_q;
    end else if (if_id_o.valid) begin
      if_id_reg_d = if_id_o;
    end
  end


  always_ff @(posedge clk_i) begin : top_seq
    if (res_i) begin
      if_id_reg_q <= '0;
    end else begin
      if_id_reg_q <= if_id_reg_d;
    end
  end

  assign an_o  = an_o_c;
  assign seg_o = seg_o_c;
endmodule
