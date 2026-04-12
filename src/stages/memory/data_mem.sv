module data_mem (
    input logic clk_i,
    input logic res_i,

    dmem_if.dmem lsu_if
);

  (* ram_style = "block" *)
  logic [WORD_WIDTH - 1:0] mem[MEM_WORDS];

  initial begin
    $readmemh("r_type.mem", mem);
  end

  /*
   WARN: Oversimplified data memory interface.
   It even only allows to load/store word for now.
  *
  */
  always_ff @(posedge clk_i) begin : seq_block
    lsu_if.data <= mem[lsu_if.data_addr.fields.word_idx];
    lsu_if.resp_valid <= lsu_if.req_valid;
  end

endmodule
