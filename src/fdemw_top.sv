import fdemw_pkg::*;
import riscv32i_pkg::*;
import pipeline_reg_pkg::*;

module fdemw_top (
    input logic clk_i,
    input logic res_i,

    input logic flush_i

);

  // Pipeline registers
  if_id_reg_t if_id_reg_q, if_id_reg_d;
  id_exe_reg_t id_exe_reg_q, id_exe_reg_d;
  exe_mem_reg_t exe_mem_reg_q, exe_mem_reg_d;
  mem_wb_reg_t mem_wb_reg_q, mem_wb_reg_d;

  // Interfaces
  imem_if imem_iff ();
  dmem_if dmem_iff ();

  // ------------- Fetch --------------------
  if_id_reg_t if_id_o;

  logic branch_taken;
  addr_t redirect_addr;

  fetch fetch_core (
      .clk_i(clk_i),
      .res_i(res_i),
      // .stall_i(stall_i),

      .imem_if(imem_iff.fetch),

      .branch_taken_i (branch_taken),
      .redirect_addr_i(redirect_addr),

      .if_id_o(if_id_o)
  );

  // ------------- Decode --------------------

  id_exe_reg_t id_exe_o;

  // To register file
  reg_idx_t decode_rs1_idx_o;
  reg_idx_t decode_rs2_idx_o;

  decode decode_core (

      .if_id_reg_i(if_id_reg_q),

      .inst_o(id_exe_o.inst),
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

      .rs1_idx_o(id_exe_o.rs1_idx),
      .rs2_idx_o(id_exe_o.rs2_idx)

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
      .r_idx_1_i(id_exe_o.rs1_idx),

      .r_en_2_i (gp_reg_r_en_2),
      .r_idx_2_i(id_exe_o.rs2_idx),

      .wr_en_i  (gp_wr_en),
      .wr_idx_i (gp_wr_idx),
      .wr_data_i(gp_wr_data),

      .r_data_1_o(id_exe_o.rs1_data),
      .r_data_2_o(id_exe_o.rs2_data)
  );

  // ------------- Execute --------------------

  exe_mem_reg_t exe_mem_o;

  forward_sel_t forward_sel_a;
  forward_sel_t forward_sel_b;

  gp_reg_t mem_forward_op;
  gp_reg_t exe_forward_op;

  always_comb begin : execute_block
    mem_forward_op = gp_wr_data;
    exe_forward_op = exe_mem_reg_q.alu_result;
  end

  execute execute_core (
      .id_exe_reg_i (id_exe_reg_q),
      .exe_mem_reg_o(exe_mem_o),

      .forward_sel_a_i(forward_sel_a),
      .forward_sel_b_i(forward_sel_b),

      .mem_forward_op_i(mem_forward_op),
      .exe_forward_op_i(exe_forward_op),

      .branch_taken_o (branch_taken),
      .redirect_addr_o(redirect_addr)

  );

  // ------------- Memory --------------------

  mem_wb_reg_t mem_wb_o;
  logic mem_stall;
  memory memory_core (

      .clk_i(clk_i),
      .res_i(res_i),
      .exe_mem_reg_i(exe_mem_reg_q),

      .mem_wb_reg_o(mem_wb_o),
      .mem_stall_o (mem_stall),

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

  // ------------- Forward Unit --------------------

  reg_idx_t rs1;
  reg_idx_t rs2;
  logic uses_rs1;
  logic uses_rs2;
  reg_idx_t exe_rd;
  reg_idx_t mem_rd;
  logic exe_write_reg;
  logic mem_write_reg;

  always_comb begin : forward_i
    rs1 = id_exe_reg_q.rs1_idx;
    rs2 = id_exe_reg_q.rs2_idx;

    uses_rs1 = id_exe_reg_q.uses_rs1;
    uses_rs2 = id_exe_reg_q.uses_rs2;

    exe_rd = exe_mem_reg_q.id_exe_reg.rd_idx;
    mem_rd = mem_wb_reg_q.exe_mem_reg.id_exe_reg.rd_idx;

    exe_write_reg = exe_mem_reg_q.id_exe_reg.is_reg_write;
    mem_write_reg = mem_wb_reg_q.exe_mem_reg.id_exe_reg.is_reg_write;
  end

  forward_unit forward_unit (
      .rs1_i(rs1),
      .rs2_i(rs2),
      .uses_rs1_i(uses_rs1),
      .uses_rs2_i(uses_rs2),
      .exe_rd_i(exe_rd),
      .mem_rd_i(mem_rd),
      .exe_write_reg_i(exe_write_reg),
      .mem_write_reg_i(mem_write_reg),

      .forward_sel_a_o(forward_sel_a),
      .forward_sel_b_o(forward_sel_b)
  );

  // ------------- Control Unit --------------------

  logic pipeline_stall;
  logic flush_frontend;

  control_unit control_unit (
      .memory_stall_i(mem_stall),

      .branch_taken_i(branch_taken),

      .pipeline_stall_o(pipeline_stall),
      .flush_frontend_o(flush_frontend)

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
    end else if (flush_frontend) begin
      if_id_reg_d  = '0;
      id_exe_reg_d = '0;
    end else if (pipeline_stall) begin
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
      id_exe_reg_q  <= '0;
      exe_mem_reg_q <= '0;
      mem_wb_reg_q  <= '0;
    end else begin
      if_id_reg_q   <= if_id_reg_d;
      id_exe_reg_q  <= id_exe_reg_d;
      exe_mem_reg_q <= exe_mem_reg_d;
      mem_wb_reg_q  <= mem_wb_reg_d;
    end
  end

endmodule
