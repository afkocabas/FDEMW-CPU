module execute (
    input  id_exe_reg_t  id_exe_reg_i,
    output exe_mem_reg_t exe_mem_reg_o
);

  gp_reg_t op_a;
  gp_reg_t op_b;
  gp_reg_t alu_result;

  addr_t   pc_i;

  always_comb begin : debug_block  // WARN: Debug.
    pc_i = id_exe_reg_i.pc;
  end

  always_comb begin : alu_op_comb
    op_a = '0;
    op_b = '0;

    unique case (id_exe_reg_i.alu_src1)
      SRC1_RS1:  op_a = id_exe_reg_i.rs1_data;
      SRC1_IMM:  op_a = id_exe_reg_i.imm;
      SRC1_ZERO: op_a = '0;
      SRC1_PC:   op_a = id_exe_reg_i.pc;
      default:   op_a = '0;

    endcase

    unique case (id_exe_reg_i.alu_src2)
      SRC2_RS2: op_b = id_exe_reg_i.rs2_data;
      SRC2_IMM: op_b = id_exe_reg_i.imm;
      default:  op_b = '0;
    endcase

  end

  ALU alu (
      .alu_op_i(id_exe_reg_i.alu_op),
      .op_a_i(op_a),
      .op_b_i(op_b),
      .alu_result_o(alu_result)
  );

  always_comb begin : output_comb
    exe_mem_reg_o.id_exe_reg = id_exe_reg_i;
    exe_mem_reg_o.alu_result = alu_result;
  end

endmodule
