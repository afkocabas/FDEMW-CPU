module execute (
    input logic clk_i,
    input logic res_i,
    input id_exe_reg_t id_exe_reg_i,

    output exe_wb_reg_t exe_wb_reg_o
);

  ALU alu ();

  // Internal signals

  always_comb begin : output_comb

  end

endmodule
