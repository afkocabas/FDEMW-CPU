import fdemw_pkg::*;

module data_mem (
    input logic clk_i,

    dmem_if.dmem dmem
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
    if (!dmem.req_valid) begin
      dmem.resp_valid <= LOW;
      dmem.r_data <= '0;
    end else begin
      if (dmem.wr_en) begin
        mem[dmem.m_addr] <= dmem.wr_data;
        dmem.resp_valid  <= LOW;
      end else if (dmem.r_en) begin
        dmem.r_data <= mem[dmem.m_addr];
        dmem.resp_valid <= HIGH;
      end
    end
  end

endmodule
