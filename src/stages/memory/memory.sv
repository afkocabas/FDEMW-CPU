import fdemw_pkg::*;
import pipeline_reg_pkg::*;

module memory (

    input logic clk_i,
    input logic res_i,
    input exe_mem_reg_t exe_mem_reg_i,

    output mem_wb_reg_t mem_wb_reg_o,

    dmem_if.core dmem_if
);

  typedef enum {
    IDLE,
    WAIT_RESP
  } state_t;

  state_t state_q, state_d;


  // Internal singals
  logic r_en, wr_en;
  logic  i_reg_valid;
  addr_t m_addr;
  word_t wr_data;

  always_comb begin
    r_en = exe_mem_reg_i.id_exe_reg.is_mem_read;
    wr_en = exe_mem_reg_i.id_exe_reg.is_mem_write;
    m_addr = exe_mem_reg_i.alu_result;
    wr_data = exe_mem_reg_i.id_exe_reg.rs2_data;
    i_reg_valid = exe_mem_reg_i.id_exe_reg.valid;
  end

  always_comb begin : output_comb
    mem_wb_reg_o.r_data = '0;
    mem_wb_reg_o.exe_mem_reg = '0;

    dmem_if.r_en = LOW;
    dmem_if.req_valid = LOW;
    dmem_if.wr_en = LOW;
    state_d = state_q;

    dmem_if.m_addr = m_addr;
    dmem_if.wr_data = wr_data;

    unique case (state_q)
      IDLE: begin
        if (i_reg_valid) begin
          if (r_en) begin
            dmem_if.r_en = HIGH;
            dmem_if.req_valid = HIGH;

            state_d = WAIT_RESP;
          end else if (wr_en) begin
            dmem_if.wr_en = HIGH;
            dmem_if.req_valid = HIGH;

          end else begin
            mem_wb_reg_o.exe_mem_reg = exe_mem_reg_i;
          end
        end
      end
      WAIT_RESP: begin
        dmem_if.req_valid = HIGH;
        if (dmem_if.resp_valid) begin

          // Latch the result
          mem_wb_reg_o.r_data = dmem_if.r_data;
          mem_wb_reg_o.exe_mem_reg = exe_mem_reg_i;

          if (!i_reg_valid) begin
            state_d = IDLE;
          end else begin
            if (r_en) begin
              dmem_if.req_valid = HIGH;
              dmem_if.r_en = HIGH;

            end else if (wr_en) begin
              dmem_if.wr_en = HIGH;
              dmem_if.req_valid = HIGH;
            end
          end
        end
      end
    endcase
  end

  always_ff @(posedge clk_i) begin : seq_block
    if (res_i) begin
      state_q <= IDLE;
    end else begin
      state_q <= state_d;
    end
  end
endmodule

