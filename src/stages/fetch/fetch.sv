import fdemw_pkg::*;
import riscv32i_pkg::*;

module fetch (
    input logic res_i,
    input logic clk_i,

    input logic stall_i,

    input logic flush_i,
    input logic flush_addr_i,

    output if_id_reg_t if_id_o,
    imem_if.fetch imem_if
);

  /* State Registers and Next State Signals*/
  addr_t prg_cnt_q, prg_cnt_d;
  if_id_reg_t if_id_reg_q, if_id_reg_d;
  logic [26:0] cnt_q, cnt_d;  // Clock divider
  logic has_active_req_q, has_active_req_d;


  /* Internal signals */
  logic  is_cnt_done;
  logic  req_valid_c;
  addr_t inst_addr_c;

  always_comb begin
    is_cnt_done = (cnt_q == '1);
  end

  always_comb begin : fsm_block
    prg_cnt_d = prg_cnt_q;
    if_id_reg_d = if_id_reg_q;
    has_active_req_d = has_active_req_q;

    inst_addr_c = prg_cnt_q;
    req_valid_c = has_active_req_q;

    // Flush has the priority
    if (flush_i) begin
      prg_cnt_d = '0;
      if_id_reg_d = '0;
      has_active_req_d = LOW;

      inst_addr_c = prg_cnt_q;
    end else
    if (stall_i) begin

    end else begin
      if (!has_active_req_q) begin
        has_active_req_d = HIGH;
      end
      if (has_active_req_q && imem_if.resp_valid) begin
        if (is_cnt_done) begin

          prg_cnt_d = prg_cnt_q + 4;

          if_id_reg_d.inst = imem_if.inst;
          if_id_reg_d.pc = prg_cnt_q;
          if_id_reg_d.valid = HIGH;

        end
      end
    end
  end

  always_comb begin : comb_block
    cnt_d = cnt_q;
    if (is_cnt_done) begin
      cnt_d = '0;
    end else begin
      cnt_d = cnt_q + 1;
    end
  end


  always_ff @(posedge clk_i) begin : seq_block
    if (res_i) begin
      cnt_q <= '0;
      prg_cnt_q <= '0;
      if_id_reg_q <= '0;
      has_active_req_q <= '0;
    end else begin
      cnt_q <= cnt_d;
      if (is_cnt_done) begin
        prg_cnt_q <= prg_cnt_d;
        if_id_reg_q <= if_id_reg_d;
        has_active_req_q <= has_active_req_d;
      end
    end

  end

  assign if_id_o = if_id_reg_q;

  assign imem_if.req_valid = req_valid_c;
  assign imem_if.inst_addr = inst_addr_c;

endmodule
