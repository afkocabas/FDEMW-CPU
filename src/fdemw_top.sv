import fdemw_pkg::*;
import riscv32i_pkg::*;
import pipeline_reg_pkg::*;

module fdemw_top (
    input logic clk_i,
    input logic res_i,


    input logic stall_i,
    input logic flush_i,

    output seg_t seg_o,
    output logic [3:0] an_o
);

  // Internal signals (wires of other modules)
  inst_format_e dec_inst_kind;

  // Pipeline registers
  if_id_reg_t if_id_reg_q, if_id_reg_d;
  id_exe_reg_t id_exe_reg_q, id_exe_reg_d;

  // Interfaces
  imem_if imem_iff ();

  // Internal signals
  logic [3:0] an_o_c;
  seg_t seg_o_c;

  always_comb begin : assign_comb
    an_o_c = 4'b1110;
  end

  // always_comb begin : seg_comb
  //   unique case (dec_inst_kind)
  //     R_T: seg_o_c = 7'b0001000;
  //     I_T: seg_o_c = 7'b1001111;
  //     S_T: seg_o_c = 7'b0010010;
  //     B_T: seg_o_c = 7'b0000000;
  //     U_T: seg_o_c = 7'b1000001;
  //     J_T: seg_o_c = 7'b1100001;
  //     INST_INVALID: seg_o_c = 7'b0111111;
  //     default: seg_o_c = 7'b0111111;
  //   endcase
  // end

  always_comb begin : seg_comb
    unique case (id_exe_reg_q.rd_idx)
      4'd0: seg_o_c = 7'b1000000;  // 0
      4'd1: seg_o_c = 7'b1111001;  // 1
      4'd2: seg_o_c = 7'b0100100;  // 2
      4'd3: seg_o_c = 7'b0110000;  // 3
      4'd4: seg_o_c = 7'b0011001;  // 4
      4'd5: seg_o_c = 7'b0010010;  // 5
      4'd6: seg_o_c = 7'b0000010;  // 6
      4'd7: seg_o_c = 7'b1111000;  // 7
      4'd8: seg_o_c = 7'b0000000;  // 8
      4'd9: seg_o_c = 7'b0010000;  // 9
      4'd10: seg_o_c = 7'b0001000;  // A (10)
      default: seg_o_c = 7'b0111111;
    endcase
  end

  // ------------- Fetch --------------------
  if_id_reg_t if_id_o;

  fetch fetch_core (
      .clk_i  (clk_i),
      .res_i  (res_i),
      .stall_i(stall_i),

      .imem_if(imem_iff.fetch),

      .if_id_o(if_id_o)
  );

  // ------------- Decode --------------------
  id_exe_reg_t id_exe_o;

  // To register file
  reg_idx_t decode_rs1_idx_o;
  reg_idx_t decode_rs2_idx_o;

  decode decode_core (

      .if_id_reg_i(if_id_reg_q),

      .inst_kind_o(id_exe_o.inst_kind),
      .imm_o(id_exe_o.imm),
      .rd_idx_o(id_exe_o.rd_idx),
      .alu_op_o(id_exe_o.alu_op),
      .pc_o(id_exe_o.pc),
      .alu_src1_o(id_exe_o.alu_src1),
      .alu_src2_o(id_exe_o.alu_src2),
      .wb_sel_o(id_exe_o.wb_sel),
      .branch_type_o(id_exe_o.branch_type),

      .valid_o(id_exe_o.valid),
      .illegal_inst_o(id_exe_o.illegal_inst),
      .uses_rs1_o(id_exe_o.uses_rs1),
      .uses_rs2_o(id_exe_o.uses_rs2),
      .is_reg_write_o(id_exe_o.is_reg_write),
      .is_mem_read_o(id_exe_o.is_mem_read),
      .is_mem_write_o(id_exe_o.is_mem_write),
      .is_branch_o(id_exe_o.is_branch),
      .is_jal_o(id_exe_o.is_jal),
      .is_jalr_o(id_exe_o.is_jalr),


      .rs1_idx_o(decode_rs1_idx_o),
      .rs2_idx_o(decode_rs2_idx_o)

  );

  // ---------------- Register File ----------------

  // TODO: Handle these placeholders
  logic gp_reg_r_en_1 = HIGH;
  logic gp_reg_r_en_2 = HIGH;
  logic gp_reg_wr_en = LOW;
  reg_idx_t gp_wr_idx = '0;
  reg_idx_t gp_wr_data = '0;

  gp_reg_file reg_file (
      .clk_i(clk_i),
      .res_i(res_i),

      .r_en_1_i (gp_reg_r_en_1),
      .r_idx_1_i(decode_rs1_idx_o),

      .r_en_2_i (gp_reg_r_en_2),
      .r_idx_2_i(decode_rs2_idx_o),

      .wr_en_i  (gp_reg_wr_en),
      .wr_idx_i (gp_wr_idx),
      .wr_data_i(gp_wr_data),

      .r_data_1_o(id_exe_o.rs1_data),
      .r_data_2_o(id_exe_o.rs2_data)
  );

  // ------------- Instruction Memory --------------------

  inst_mem i_mem (
      .clk_i(clk_i),

      .fetch_if(imem_iff.imem)
  );


  always_comb begin : reg_updates
    if_id_reg_d = if_id_reg_q;

    if (flush_i) begin
      if_id_reg_d = '0;
    end else if (stall_i) begin
      if_id_reg_d = if_id_reg_q;
      // TODO: The following if_id_o.valid is for the sake of debugging; remove that later.
    end else if (if_id_o.valid) begin
      // IF/ID Register
      if_id_reg_d = if_id_o;
    end

  end
  always_comb begin
    id_exe_reg_d = id_exe_reg_q;

    if (flush_i) begin
      id_exe_reg_d = '0;
    end else if (stall_i) begin
      id_exe_reg_d = id_exe_reg_q;
    end else begin
      id_exe_reg_d = id_exe_o;
    end

  end

  always_ff @(posedge clk_i) begin : top_seq
    if (res_i) begin
      if_id_reg_q  <= '0;
      id_exe_reg_q <= '0;
    end else begin
      if_id_reg_q  <= if_id_reg_d;
      id_exe_reg_q <= id_exe_reg_d;
    end
  end

  assign an_o  = an_o_c;
  assign seg_o = seg_o_c;
endmodule
