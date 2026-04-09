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

  typedef enum {
    IDLE,
    WAIT_RESP
  } f_state_t;

  /* State Registers and Next State Signals*/
  f_state_t state_q, state_d;
  addr_t prg_cnt_q, prg_cnt_d;
  if_id_reg_t if_id_reg_q, if_id_reg_d;
  logic [26:0] cnt_q, cnt_d;  // Clock divider


  /* Internal signals */
  logic  is_cnt_done;
  logic  req_valid_c;
  addr_t inst_addr_c;

  always_comb begin : derived_macros
    is_cnt_done = (cnt_q == '1);
  end

  always_comb begin : fsm_block
    // Default state register assingments
    state_d = state_q;
    prg_cnt_d = prg_cnt_q;
    if_id_reg_d = if_id_reg_q;

    // Default output signal assignments
    inst_addr_c = prg_cnt_q;
    req_valid_c = LOW;

    // Flush has should should be immediate.
    if (flush_i) begin
      prg_cnt_d = flush_addr_i;
      if_id_reg_d = '0;
      state_d = IDLE;
    end else begin
      unique case (state_q)
        IDLE: begin
          if (!stall_i) begin
            req_valid_c = HIGH;
            inst_addr_c = prg_cnt_q;
            state_d = WAIT_RESP;
          end
        end
        WAIT_RESP: begin
          req_valid_c = HIGH;
          if (imem_if.resp_valid && is_cnt_done) begin
            if (!stall_i) begin
              prg_cnt_d = prg_cnt_q + 4;

              if_id_reg_d.inst = imem_if.inst;
              if_id_reg_d.pc = prg_cnt_q;
              if_id_reg_d.valid = HIGH;

              // WARN: The following line incurs a bubble in the pipeline.
              // The reason is the following:
              // After state transition, IDLE does not check memory response in the same cycle, it only issues the transition to WAIT_RESP.
              // Only after then, memory repsonse is checked.

              // state_d = IDLE;

            end else begin
              // TODO: If the memory responds but there is stall, buffer the
              // instruction or leave it here.
            end
          end
        end
      endcase
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
      state_q <= IDLE;
    end else begin
      cnt_q <= cnt_d;
      if (is_cnt_done) begin
        prg_cnt_q <= prg_cnt_d;
        if_id_reg_q <= if_id_reg_d;
        state_q <= state_d;
      end
    end

  end

  assign if_id_o = if_id_reg_q;

  assign imem_if.req_valid = req_valid_c;
  assign imem_if.inst_addr = inst_addr_c;

endmodule
