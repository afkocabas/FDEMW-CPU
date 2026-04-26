module execute (
    input  id_exe_reg_t  id_exe_reg_i,
    output exe_mem_reg_t exe_mem_reg_o,

    input forward_sel_t forward_sel_a_i,
    input forward_sel_t forward_sel_b_i,

    input gp_reg_t mem_forward_op_i,
    input gp_reg_t exe_forward_op_i,

    output logic  branch_taken_o,
    output addr_t redirect_addr_o

);

  gp_reg_t op_a;
  gp_reg_t op_b;
  gp_reg_t alu_result;

  always_comb begin : alu_op_comb
    op_a = '0;
    op_b = '0;

    // Driving Operand A and Operand B
    unique case (id_exe_reg_i.alu_src1)
      SRC1_RS1: begin
        if (forward_sel_a_i == FORWARD_FROM_EXE) op_a = exe_forward_op_i;
        else if (forward_sel_a_i == FORWARD_FROM_MEM) op_a = mem_forward_op_i;
        else op_a = id_exe_reg_i.rs1_data;
      end
      SRC1_IMM:  op_a = id_exe_reg_i.imm;
      SRC1_ZERO: op_a = '0;
      SRC1_PC:   op_a = id_exe_reg_i.pc;
    endcase

    unique case (id_exe_reg_i.alu_src2)
      SRC2_RS2: begin
        if (forward_sel_b_i == FORWARD_FROM_EXE) op_b = exe_forward_op_i;
        else if (forward_sel_b_i == FORWARD_FROM_MEM) op_b = mem_forward_op_i;
        else op_b = id_exe_reg_i.rs2_data;
      end
      SRC2_IMM: op_b = id_exe_reg_i.imm;
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

    if (forward_sel_a_i == FORWARD_FROM_EXE) exe_mem_reg_o.id_exe_reg.rs1_data = exe_forward_op_i;
    else if (forward_sel_a_i == FORWARD_FROM_MEM);
    exe_mem_reg_o.id_exe_reg.rs1_data = mem_forward_op_i;

    if (forward_sel_b_i == FORWARD_FROM_EXE) exe_mem_reg_o.id_exe_reg.rs2_data = exe_forward_op_i;
    else if (forward_sel_b_i == FORWARD_FROM_MEM);
    exe_mem_reg_o.id_exe_reg.rs2_data = mem_forward_op_i;

    exe_mem_reg_o.alu_result = alu_result;

    redirect_addr_o = alu_result;

    // TODO: Branch (B type instructions) logic should be implemented.
    branch_taken_o = (id_exe_reg_i.is_jal || id_exe_reg_i.is_jalr);
  end

endmodule
