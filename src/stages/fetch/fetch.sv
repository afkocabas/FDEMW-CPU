import fdemw_pkg::*;

module fetch (
    input logic clk_i,
    input logic res_i,

    output addr_t adrr_o
);

  /* State Registers and Next State Signals*/

  // Program Counter
  addr_t prg_cnt_q, prg_cnt_d;
  // Clock divider
  logic [26:0] cnt_q, cnt_d;

  // Internal signals
  logic is_cnt_done = cnt_q == '1;

  always_comb begin : comb_block
    cnt_d = cnt_q;
    prg_cnt_d = prg_cnt_q;

    if (is_cnt_done) begin
      cnt_d = '0;
      prg_cnt_d = prg_cnt_q + 1;
    end else begin
      cnt_d = cnt_q + 1;
    end
  end


  always_ff @(posedge clk_i) begin : seq_block
    if (res_i) begin
      cnt_q <= '0;
      prg_cnt_q <= '0;
    end else begin
      cnt_q <= cnt_d;
      prg_cnt_q <= prg_cnt_d;
    end

  end

  assign adrr_o = prg_cnt_q;

endmodule
