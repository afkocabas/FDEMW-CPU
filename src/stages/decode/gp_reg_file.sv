import fdemw_pkg::*;

module gp_reg_file (
    input logic clk_i,
    input logic res_i,

    // Read ports (2)
    input logic   r_en_1_i,
    input reg_idx_t r_idx_1_i,

    input logic   r_en_2_i,
    input reg_idx_t r_idx_2_i,

    // Write ports (1)
    input logic wr_en_i,
    input reg_idx_t wr_idx_i,
    input gp_reg_t wr_data_i,

    output gp_reg_t r_data_1_o,
    output gp_reg_t r_data_2_o
);
  reg_file_t reg_file_q, reg_file_d;

  always_comb begin : comb_block
    reg_file_d = reg_file_q;
    reg_file_d[0] = '0;

    r_data_1_o = '0;
    r_data_2_o = '0;

    if (wr_en_i && !(wr_idx_i == '0)) begin
      reg_file_d[wr_idx_i] = wr_data_i;
    end

    if (r_en_1_i) begin
      if (wr_en_i && wr_idx_i == r_idx_1_i && !(wr_idx_i == '0)) r_data_1_o = wr_data_i;
      else r_data_1_o = reg_file_q[r_idx_1_i];
    end

    if (r_en_2_i) begin
      if (wr_en_i && wr_idx_i == r_idx_2_i && !(wr_idx_i == '0)) r_data_2_o = wr_data_i;
      else r_data_2_o = reg_file_q[r_idx_2_i];
    end
  end

  always_ff @(posedge clk_i) begin
    if (res_i) begin
      for (int i = 0; i < REG_FILE_DEPTH; i++) begin
        reg_file_q[i] <= '0;
      end
    end else begin
      reg_file_q <= reg_file_d;
    end
  end

endmodule
