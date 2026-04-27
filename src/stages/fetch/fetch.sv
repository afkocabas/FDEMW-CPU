import fdemw_pkg::*;
import riscv32i_pkg::*;

module fetch (
    input logic res_i,
    input logic clk_i,

    input logic stall_i,

    input logic  branch_taken_i,
    input addr_t redirect_addr_i,

    output if_id_reg_t if_id_o,
    imem_if.fetch imem_if
);

  // DEBUG Signals
  inst_t fetch_inst_o;
  addr_t fetch_pc_o;

  always_comb begin : debug_signals
    fetch_inst_o = if_id_o.inst;
    fetch_pc_o   = if_id_o.pc;
  end


  addr_t pc_q, pc_d;
  addr_t pc_req_q, pc_req_d;
  logic req_flight_q, req_flight_d;
  logic drop_req_q, drop_req_d;

  always_comb begin : fetch_comb
    pc_d = pc_q;
    pc_req_d = pc_req_q;
    req_flight_d = LOW;
    drop_req_d = LOW;

    if_id_o.pc = '0;
    if_id_o.inst = '0;
    if_id_o.valid = '0;

    imem_if.inst_addr = '0;
    imem_if.req_valid = LOW;

    if (res_i) begin
      imem_if.inst_addr = '0;
      imem_if.req_valid = LOW;
    end else if (branch_taken_i) begin
      pc_d = redirect_addr_i;
      drop_req_d = HIGH;
    end else if (stall_i) begin
      if (req_flight_q) begin

      end
    end else begin
      req_flight_d = HIGH;
      if (imem_if.resp_valid && !drop_req_q) begin
        if_id_o.pc = pc_req_q;
        if_id_o.inst = imem_if.inst;
        if_id_o.valid = HIGH;

        pc_d = pc_q + 4;
        pc_req_d = pc_d;

        imem_if.inst_addr = pc_d;
        imem_if.req_valid = HIGH;
      end else begin
        pc_req_d = pc_q;
        imem_if.inst_addr = pc_q;
        imem_if.req_valid = HIGH;
      end
    end
  end

  always_ff @(posedge clk_i or posedge res_i) begin : blockName
    if (res_i) begin
      pc_req_q <= '0;
      pc_q <= '0;
      req_flight_q <= LOW;
      drop_req_q <= LOW;
    end else begin
      pc_req_q <= pc_req_d;
      pc_q <= pc_d;
      req_flight_q <= req_flight_d;
      drop_req_q <= drop_req_d;
    end
  end

endmodule
