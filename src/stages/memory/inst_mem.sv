import fdemw_pkg::*;

module inst_mem (
    input logic clk_i,

    imem_if.imem fetch_if
);

  (* ram_style = "block" *)
  logic [WORD_WIDTH - 1:0] mem[MEM_WORDS];

  initial begin
    $readmemh("sw_lw.mem", mem);
  end

  always_ff @(posedge clk_i) begin : seq_block
    fetch_if.inst <= mem[fetch_if.inst_addr.fields.word_idx];
    fetch_if.resp_valid <= fetch_if.req_valid;
  end

endmodule
