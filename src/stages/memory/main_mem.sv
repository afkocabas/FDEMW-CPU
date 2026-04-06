import fdemw_pkg::*;

module main_mem (
    input logic  clk_i,
    input logic  wr_en,
    input addr_t addr_i,
    input byte_t data_i,

    output byte_t data_o
);

  (* ram_style = "block" *)
  logic [BYTE_WIDTH - 1:0] mem[MEM_BYTES];

  initial begin
    $readmemh("sample.mem", mem);
  end

  always_ff @(posedge clk_i) begin : seq_block
    if (wr_en) begin
      mem[addr_i] <= data_i;
    end
    data_o <= mem[addr_i];
  end

endmodule
