import fdemw_pkg::*;
import pipeline_reg_pkg::*;

module write_back (

    input mem_wb_reg_t mem_wb_reg_i,

    output logic wr_en_o,
    output word_t wr_data_o,
    output reg_idx_t rd_idx_o

);

  addr_t pc;
  wb_sel_t wb_sel;
  reg_idx_t rd_idx;
  gp_reg_t alu_result;
  word_t mem_data;
  inst_t inst;

  always_comb begin : assign_block
    pc = mem_wb_reg_i.exe_mem_reg.id_exe_reg.pc;
    wb_sel = mem_wb_reg_i.exe_mem_reg.id_exe_reg.wb_sel;
    rd_idx = mem_wb_reg_i.exe_mem_reg.id_exe_reg.rd_idx;
    alu_result = mem_wb_reg_i.exe_mem_reg.alu_result;
    mem_data = mem_wb_reg_i.r_data;
    inst = mem_wb_reg_i.exe_mem_reg.id_exe_reg.inst;
  end


  always_comb begin : wr_back_block
    wr_en_o   = LOW;
    rd_idx_o  = rd_idx;
    wr_data_o = '0;

    unique case (wb_sel)
      WB_NONE: wr_en_o = LOW;
      WB_ALU: begin
        wr_en_o   = HIGH;
        wr_data_o = alu_result;
      end
      WB_MEM: begin
        wr_en_o   = HIGH;
        wr_data_o = mem_data;
      end
      WB_PC4: begin
        wr_en_o   = HIGH;
        wr_data_o = pc + 4;
      end
    endcase
  end

endmodule
