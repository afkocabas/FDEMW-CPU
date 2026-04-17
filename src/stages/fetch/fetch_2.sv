import fdemw_pkg::*;
import riscv32i_pkg::*;

module fetch_2 (
    input logic  clk_i,
    input logic  res_i,
    input logic  fetch_en_i,
    input addr_t pc_i,

    output if_id_reg_t if_id_reg_o,

    imem_if.fetch imem_if
);

  addr_t pc_req_q, pc_req_d;

  always_comb begin : fetch_comb
    pc_req_d = pc_req_q;

    if_id_reg_o.pc = '0;
    if_id_reg_o.inst = '0;
    if_id_reg_o.valid = '0;

    imem_if.inst_addr = '0;
    imem_if.req_valid = LOW;


    if (imem_if.resp_valid) begin
      if_id_reg_o.pc = pc_req_q;
      if_id_reg_o.inst = imem_if.inst;
      if_id_reg_o.valid = HIGH;
    end

    if (fetch_en_i) begin
      pc_req_d = pc_i;
      imem_if.inst_addr = pc_i;
      imem_if.req_valid = HIGH;
    end

  end

  always_ff @(posedge clk_i) begin : blockName
    if (res_i) pc_req_q <= '0;
    else pc_req_q <= pc_req_d;
  end

endmodule
