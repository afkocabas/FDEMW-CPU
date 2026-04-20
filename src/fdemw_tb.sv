`timescale 1ns / 1ps

module fdemw_tb;

  logic clk;
  logic res;
  logic flush = 0;

  // Instantiate DUT
  fdemw_top dut (
      .clk_i(clk),
      .res_i(res),

      .flush_i(flush)

  );

  initial begin
    $dumpfile("fdemw_tb.vcd");
    $dumpvars(0, fdemw_tb);
  end

  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz

  initial begin
    res = 1;
    #15;
    res = 0;

    #1000;
    $finish;
  end

endmodule
