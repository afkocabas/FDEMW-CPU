import fdemw_pkg::*;

module fdemw_top (
    input logic clk_i,
    input logic res_i,

    output seg_t seg_o,
    output logic [3:0] an_o
);

  // Internal signals (wires of other modules)
  addr_t fetch_addr;
  byte_t mem_data_o, mem_data_i;
  logic mem_wr_en;


  // Internal signals
  logic [3:0] an_o_c;
  seg_t seg_o_c;

  always_comb begin : assign_comb
    an_o_c = 4'b1110;
  end

  always_comb begin : seg_comb
    unique case (mem_data_o)
      8'h00:   seg_o_c = 7'b1000000;
      8'h01:   seg_o_c = 7'b1111001;
      8'h02:   seg_o_c = 7'b0100100;
      8'h03:   seg_o_c = 7'b0110000;
      8'h04:   seg_o_c = 7'b0011001;
      8'h05:   seg_o_c = 7'b0010010;
      8'h06:   seg_o_c = 7'b0000010;
      8'h07:   seg_o_c = 7'b1111000;
      8'h08:   seg_o_c = 7'b0000000;
      8'h09:   seg_o_c = 7'b0010000;
      8'h0a:   seg_o_c = 7'b0001000;
      8'h0b:   seg_o_c = 7'b0000011;
      8'h0c:   seg_o_c = 7'b1000110;
      8'h0d:   seg_o_c = 7'b0100001;
      8'h0e:   seg_o_c = 7'b0000110;
      8'h0f:   seg_o_c = 7'b0001110;
      default: seg_o_c = 7'b1000000;
    endcase
  end


  fetch fetch_core (
      .clk_i(clk_i),
      .res_i(res_i),

      .adrr_o(fetch_addr)
  );

  main_mem mem (
      .clk_i (clk_i),
      .wr_en (mem_wr_en),
      .addr_i(fetch_addr),
      .data_i(mem_data_i),

      .data_o(mem_data_o)
  );

  assign an_o  = an_o_c;
  assign seg_o = seg_o_c;
endmodule
