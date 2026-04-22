module control_unit (
    input logic memory_stall_i,
    input logic branch_taken_i,

    output logic pipeline_stall_o,
    output logic flush_frontend_o

);

  // TODO: Complete the logic here.
  // WARNING: Unit it is not completed.

  always_comb begin : output_comb
    pipeline_stall_o = memory_stall_i;
  end
endmodule
