import riscv32i_pkg::*;
import pipeline_reg_pkg::*;

module decode (

    input if_id_reg_t if_id_reg_i,

    // To ID/EXE
    output inst_format_e inst_format_o,
    output imm_t imm_o,
    output reg_idx_t rd_idx_o,
    output alu_op_t alu_op_o,
    output addr_t pc_o,
    output alu_src1_t alu_src1_o,
    output alu_src2_t alu_src2_o,
    output wb_sel_t wb_sel_o,
    output branch_type_t branch_type_o,

    output logic valid_o,
    output logic illegal_inst_o,
    output logic uses_rs1_o,
    output logic uses_rs2_o,
    output logic is_reg_write_o,
    output logic is_mem_read_o,
    output logic is_mem_write_o,
    output logic is_branch_o,
    output logic is_jal_o,
    output logic is_jalr_o,


    // To register file
    output reg_idx_t rs1_idx_o,
    output reg_idx_t rs2_idx_o

);

  // Internal signals
  inst_t inst = if_id_reg_i.inst;
  addr_t pc = if_id_reg_i.pc;

  inst_kind_e inst_kind = get_inst_kind(inst);

  always_comb begin : output_comb
    inst_format_o = get_inst_format(inst);

    imm_o = '0;
    rd_idx_o = inst.r.rd;
    alu_op_o = get_alu_op_r_t(inst.r.funct7, inst.r.funct3);
    pc_o = pc;
    alu_src1_o = SRC1_RS1;
    alu_src2_o = SRC2_RS2;
    wb_sel_o = WB_ALU;
    branch_type_o = BR_NONE;

    valid_o = LOW;
    illegal_inst_o = HIGH;
    uses_rs1_o = LOW;
    uses_rs2_o = LOW;
    is_reg_write_o = HIGH;
    is_mem_read_o = LOW;
    is_mem_write_o = LOW;
    is_branch_o = LOW;
    is_jal_o = LOW;
    is_jalr_o = LOW;

    rs1_idx_o = inst.r.rs1;
    rs2_idx_o = inst.r.rs2;

    unique case (inst_format_o)
      R_T: begin

        imm_o = '0;
        rd_idx_o = inst.r.rd;
        alu_op_o = get_alu_op_r_t(inst.r.funct7, inst.r.funct3);
        pc_o = pc;
        alu_src1_o = SRC1_RS1;
        alu_src2_o = SRC2_RS2;
        wb_sel_o = WB_ALU;
        branch_type_o = BR_NONE;

        valid_o = !(alu_op_o == ALU_NONE);
        illegal_inst_o = !valid_o;
        uses_rs1_o = HIGH;
        uses_rs2_o = HIGH;
        is_reg_write_o = HIGH;
        is_mem_read_o = LOW;
        is_mem_write_o = LOW;
        is_branch_o = LOW;
        is_jal_o = LOW;
        is_jalr_o = LOW;


        rs1_idx_o = inst.r.rs1;
        rs2_idx_o = inst.r.rs2;

      end
      I_T: begin
        imm_o = {{20{inst.i.imm[11]}}, inst.i.imm};
        rd_idx_o = inst.i.rd;
        pc_o = pc;
        alu_src1_o = SRC1_RS1;
        alu_src2_o = SRC2_IMM;
        branch_type_o = BR_NONE;
        uses_rs1_o = HIGH;
        uses_rs2_o = LOW;
        is_reg_write_o = HIGH;
        is_mem_write_o = LOW;
        is_branch_o = LOW;
        is_jal_o = LOW;
        is_jalr_o = LOW;
        rs1_idx_o = inst.i.rs1;
        rs2_idx_o = '0;
        valid_o = is_valid_i_t(inst_kind, inst.i.imm[11:5], inst.i.funct3);
        illegal_inst_o = !valid_o;

        unique case (inst_kind)
          IK_I_ALU: begin
            wb_sel_o = WB_ALU;
            is_mem_read_o = LOW;
            alu_op_o = get_alu_op_i_t(inst.i.imm[11:5], inst.i.funct3);
          end
          IK_LOAD: begin
            wb_sel_o = WB_MEM;
            is_mem_read_o = HIGH;
            alu_op_o = ADD;
          end
          IK_JALR: begin
            wb_sel_o      = WB_PC4;
            is_mem_read_o = LOW;
            alu_op_o      = ADD;
            is_jalr_o     = HIGH;
          end
        endcase

      end
      S_T: begin

        imm_o = {{20{inst.s.imm_11_5[6]}}, inst.s.imm_11_5, inst.s.imm_4_0};
        rd_idx_o = '0;
        alu_op_o = ADD;
        pc_o = pc;
        alu_src1_o = SRC1_RS1;
        alu_src2_o = SRC2_IMM;
        wb_sel_o = WB_NONE;
        branch_type_o = BR_NONE;

        valid_o = is_valid_s_t(inst.s.funct3);
        illegal_inst_o = !valid_o;
        uses_rs1_o = HIGH;
        uses_rs2_o = HIGH;
        is_reg_write_o = LOW;
        is_mem_read_o = LOW;
        is_mem_write_o = HIGH;
        is_branch_o = LOW;
        is_jal_o = LOW;
        is_jalr_o = LOW;

        rs1_idx_o = inst.s.rs1;
        rs2_idx_o = inst.s.rs2;

      end
      U_T: begin
        imm_o = {inst.u.imm_31_12, 12'b0};
        rd_idx_o = inst.u.rd;
        alu_op_o = ADD;
        pc_o = pc;
        branch_type_o = BR_NONE;
        uses_rs1_o = LOW;
        uses_rs2_o = LOW;
        is_mem_read_o = LOW;
        is_mem_write_o = LOW;
        is_branch_o = LOW;
        is_jal_o = LOW;
        is_jalr_o = LOW;
        wb_sel_o = WB_ALU;
        is_reg_write_o = HIGH;

        rs1_idx_o = '0;
        rs2_idx_o = '0;

        unique case (inst_kind)
          IK_LUI: begin
            alu_src1_o = SRC1_ZERO;
            alu_src2_o = SRC2_IMM;
          end
          IK_AUIPC: begin
            alu_src1_o = SRC1_PC;
            alu_src2_o = SRC2_IMM;
          end
        endcase

        valid_o = is_valid_u_t(inst_kind);
        illegal_inst_o = !valid_o;

      end
      B_T: begin
        imm_o = {
          {19{inst.b.imm_12}}, inst.b.imm_12, inst.b.imm_11, inst.b.imm_10_5, inst.b.imm_4_1, 1'b0
        };

        rd_idx_o = '0;
        alu_op_o = SUB;
        pc_o = pc;
        alu_src1_o = SRC1_RS1;
        alu_src2_o = SRC2_RS2;
        wb_sel_o = WB_NONE;

        uses_rs1_o = HIGH;
        uses_rs2_o = HIGH;
        is_reg_write_o = LOW;
        is_mem_read_o = LOW;
        is_mem_write_o = LOW;
        is_branch_o = HIGH;
        is_jal_o = LOW;
        is_jalr_o = LOW;

        rs1_idx_o = inst.b.rs1;
        rs2_idx_o = inst.b.rs2;

        branch_type_o = get_branch_type(inst.b.funct3);

        valid_o = (branch_type_o != BR_NONE);
        illegal_inst_o = !valid_o;

      end
    endcase
  end

endmodule
