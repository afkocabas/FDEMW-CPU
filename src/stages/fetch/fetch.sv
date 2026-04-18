import fdemw_pkg::*;
import riscv32i_pkg::*;

module fetch (
    input logic res_i,
    input logic clk_i,

    input logic stall_i,

    input logic  flush_i,
    input addr_t flush_addr_i,

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

  always_comb begin : fsm_block
    // Default state register assingments
    state_d = state_q;
    prg_cnt_d = prg_cnt_q;
    if_id_o = '0;

    // Default output signal assignments
    imem_if.inst_addr = prg_cnt_q;
    imem_if.req_valid = LOW;

    // Flush has should should be immediate.
    if (res_i) begin
      if_id_o = '0;
      imem_if.inst_addr = '0;
      imem_if.req_valid = LOW;
    end else if (flush_i) begin
      imem_if.req_valid = LOW;
      if_id_o = '0;

      prg_cnt_d = flush_addr_i;
      state_d = IDLE;
    end else begin
      unique case (state_q)
        IDLE: begin
          if (!stall_i) begin
            imem_if.req_valid = HIGH;
            imem_if.inst_addr = prg_cnt_q;
            state_d = WAIT_RESP;
          end
        end
        WAIT_RESP: begin
          imem_if.req_valid = HIGH;
          if (imem_if.resp_valid) begin
            if (!stall_i) begin
              // TODO: PC is not always PC + 4
              prg_cnt_d = prg_cnt_q + 4;
              imem_if.inst_addr = prg_cnt_d;

              if_id_o.inst = imem_if.inst;
              if_id_o.pc = prg_cnt_q;
              if_id_o.valid = HIGH;

            end else begin
              // TODO: If the memory responds but there is stall, buffer the
              // instruction or leave it here.
            end
          end
        end
      endcase
    end
  end


  always_ff @(posedge clk_i or posedge res_i) begin : seq_block
    if (res_i) begin
      prg_cnt_q <= '0;
      state_q   <= IDLE;
    end else begin
      prg_cnt_q <= prg_cnt_d;
      state_q   <= state_d;
    end

  end

endmodule
