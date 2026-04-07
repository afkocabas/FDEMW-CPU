import fdemw_pkg::*;

module inst_mem (
    input logic  clk_i,
    input addr_t addr_i,

    output inst_t inst_o
);

  (* ram_style = "block" *)
  logic [WORD_WIDTH - 1:0] mem[MEM_WORDS];

  initial begin
    $readmemh("sample.mem", mem);
  end

  always_ff @(posedge clk_i) begin : seq_block
    inst_o <= mem[addr_i.fields.word_idx];
  end

endmodule
