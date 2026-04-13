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
  exe_mem_reg_t exe_mem_reg_q, exe_mem_reg_d;
  mem_wb_reg_t mem_wb_reg_q, mem_wb_reg_d;

  // Interfaces
  imem_if imem_iff ();
  dmem_if dmem_iff ();

  // Internal signals
  logic [3:0] an_o_c;
  seg_t seg_o_c;

  always_comb begin : assign_comb
    an_o_c = 4'b1110;
  end

  always_comb begin : seg_comb
    unique case (exe_mem_reg_q.id_exe_reg.rd_idx)
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
  localparam id_exe_reg_t ID_EXE_REG_RESET = '{
      inst_format  : INST_INVALID,  // replace with your real default enum
      imm          : '0,
      rd_idx       : reg_idx_t'('0),  // or a named enum/member if reg_idx_t is enum
      alu_op       : ALU_NONE,  // replace with your real default enum
      pc           : '0,
      alu_src1     : SRC1_RS1,  // or your safe default
      alu_src2     : SRC2_RS2,  // or your safe default
      wb_sel       : WB_ALU,  // or your safe default
      branch_type  : BR_NONE,

      valid        : 1'b0,
      illegal_inst : 1'b0,
      uses_rs1     : 1'b0,
      uses_rs2     : 1'b0,
      is_reg_write : 1'b0,
      is_mem_read  : 1'b0,
      is_mem_write : 1'b0,
      is_branch    : 1'b0,
      is_jal       : 1'b0,
      is_jalr      : 1'b0,

      rs1_data     : '0,
      rs2_data     : '0
  };

  id_exe_reg_t id_exe_o;

  // To register file
  reg_idx_t decode_rs1_idx_o;
  reg_idx_t decode_rs2_idx_o;

  decode decode_core (

      .if_id_reg_i(if_id_reg_q),

      .inst_format_o(id_exe_o.inst_format),
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

  logic gp_reg_r_en_1 = HIGH;
  logic gp_reg_r_en_2 = HIGH;
  logic gp_wr_en;
  reg_idx_t gp_wr_idx;
  gp_reg_t gp_wr_data;

  gp_reg_file reg_file (
      .clk_i(clk_i),
      .res_i(res_i),

      .r_en_1_i (gp_reg_r_en_1),
      .r_idx_1_i(decode_rs1_idx_o),

      .r_en_2_i (gp_reg_r_en_2),
      .r_idx_2_i(decode_rs2_idx_o),

      .wr_en_i  (gp_wr_en),
      .wr_idx_i (gp_wr_idx),
      .wr_data_i(gp_wr_data),

      .r_data_1_o(id_exe_o.rs1_data),
      .r_data_2_o(id_exe_o.rs2_data)
  );

  // ------------- Execute --------------------

  exe_mem_reg_t exe_mem_o;
  execute execute_core (
      .id_exe_reg_i (id_exe_reg_q),
      .exe_mem_reg_o(exe_mem_o)
  );

  // ------------- Memory --------------------

  mem_wb_reg_t mem_wb_o;
  memory memory_core (

      .clk_i(clk_i),
      .res_i(res_i),
      .exe_mem_reg_i(exe_mem_reg_q),

      .mem_wb_reg_o(mem_wb_o),

      .dmem_if(dmem_iff.core)
  );

  // ------------- Write Back --------------------

  write_back wb (

      .mem_wb_reg_i(mem_wb_reg_q),

      .wr_en_o  (gp_wr_en),
      .wr_data_o(gp_wr_data),
      .rd_idx_o (gp_wr_idx)

  );

  // ------------- Instruction Memory --------------------

  inst_mem i_mem (
      .clk_i(clk_i),

      .fetch_if(imem_iff.imem)
  );

  // ------------- Data Memory --------------------

  data_mem d_mem (
      .clk_i(clk_i),

      .dmem(dmem_iff.dmem)
  );

  always_comb begin
    if_id_reg_d   = if_id_reg_q;
    id_exe_reg_d  = id_exe_reg_q;
    exe_mem_reg_d = exe_mem_reg_q;
    mem_wb_reg_d  = mem_wb_reg_q;

    if (flush_i) begin
      if_id_reg_d   = '0;
      id_exe_reg_d  = '0;
      exe_mem_reg_d = '0;
      mem_wb_reg_d  = '0;
    end else if (stall_i) begin
      if_id_reg_d   = if_id_reg_q;
      id_exe_reg_d  = id_exe_reg_q;
      exe_mem_reg_d = exe_mem_reg_q;
      mem_wb_reg_d  = mem_wb_reg_q;
    end else begin
      if_id_reg_d   = if_id_o;
      id_exe_reg_d  = id_exe_o;
      exe_mem_reg_d = exe_mem_o;
      mem_wb_reg_d  = mem_wb_o;
    end
  end

  always_ff @(posedge clk_i or posedge res_i) begin : top_seq
    if (res_i) begin
      if_id_reg_q   <= '0;
      id_exe_reg_q  <= ID_EXE_REG_RESET;
      exe_mem_reg_q <= '0;
      mem_wb_reg_q  <= '0;
    end else begin
      if_id_reg_q   <= if_id_reg_d;
      id_exe_reg_q  <= id_exe_reg_d;
      exe_mem_reg_q <= exe_mem_reg_d;
      mem_wb_reg_q  <= mem_wb_reg_d;
    end
  end

  assign an_o  = an_o_c;
  assign seg_o = seg_o_c;
endmodule
