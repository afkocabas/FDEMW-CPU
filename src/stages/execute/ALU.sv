module ALU (

    input alu_op_t   alu_op_i,
    input alu_src1_t op_a_i,
    input alu_src2_t op_b_i,

    output gp_reg_t alu_result_o

);

  always_comb begin
    alu_result_o = '0;
    unique case (alu_op_i)
      ADD:      alu_result_o = op_a_i + op_b_i;
      SUB:      alu_result_o = op_a_i - op_b_i;
      SLL:      alu_result_o = op_a_i << op_b_i[$clog2($bits(op_a_i))-1:0];
      SRL:      alu_result_o = op_a_i >> op_b_i[$clog2($bits(op_a_i))-1:0];
      SRA:      alu_result_o = $signed(op_a_i) >>> op_b_i[$clog2($bits(op_a_i))-1:0];
      SLT:      alu_result_o = ($signed(op_a_i) < $signed(op_b_i));
      SLTU:     alu_result_o = (op_a_i < op_b_i);
      XOR:      alu_result_o = op_a_i ^ op_b_i;
      OR:       alu_result_o = op_a_i | op_b_i;
      AND:      alu_result_o = op_a_i & op_b_i;
      PASS_A:   alu_result_o = op_a_i;
      PASS_B:   alu_result_o = op_b_i;
      ALU_NONE: alu_result_o = '0;
    endcase
  end

endmodule
