`timescale 1ns / 1ps

module fdemw_tb;

  logic clk;
  logic res;
  logic stall = 0;
  logic flush = 0;

  seg_t seg;
  logic [3:0] an;

  // Instantiate DUT
  fdemw_top dut (
      .clk_i(clk),
      .res_i(res),

      .stall_i(stall),
      .flush_i(flush),

      .seg_o(seg),
      .an_o (an)
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

    #300;
    $finish;
  end

endmodule
