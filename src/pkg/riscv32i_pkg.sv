package riscv32i_pkg;

  import fdemw_pkg::*;
  // Instruction sub-types
  typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
  } r_t;

  typedef struct packed {
    logic [11:0] imm;
    logic [4:0]  rs1;
    logic [2:0]  funct3;
    logic [4:0]  rd;
    logic [6:0]  opcode;
  } i_t;

  typedef struct packed {
    logic [6:0] imm_11_5;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] imm_4_0;
    logic [6:0] opcode;
  } s_t;

  typedef struct packed {
    logic [19:0] imm_31_12;
    logic [4:0]  rd;
    logic [6:0]  opcode;
  } u_t;

  typedef struct packed {
    logic       imm_12;    // inst[31]
    logic [5:0] imm_10_5;  // inst[30:25]
    logic [4:0] rs2;       // inst[24:20]
    logic [4:0] rs1;       // inst[19:15]
    logic [2:0] funct3;    // inst[14:12]
    logic [3:0] imm_4_1;   // inst[11:8]
    logic       imm_11;    // inst[7]
    logic [6:0] opcode;    // inst[6:0]
  } b_t;

  typedef struct packed {
    logic       imm_20;     // inst[31]
    logic [9:0] imm_10_1;   // inst[30:21]
    logic       imm_11;     // inst[20]
    logic [7:0] imm_19_12;  // inst[19:12]
    logic [4:0] rd;         // inst[11:7]
    logic [6:0] opcode;     // inst[6:0]
  } j_t;

  typedef union packed {
    logic [INST_WIDTH-1:0]                     inst;
    logic [INST_BYTES - 1:0][BYTE_WIDTH - 1:0] bytes;
    r_t                                        r;
    i_t                                        i;
    s_t                                        s;
    b_t                                        b;
    u_t                                        u;
    j_t                                        j;
  } inst_t;

  typedef enum {
    R_T,
    I_T,
    S_T,
    B_T,
    U_T,
    J_T,
    INVALID_T
  } inst_format_e;

  function automatic inst_format_e get_inst_kind(inst_t inst);
    logic [6:0] opcode;
    opcode = inst[6:0];

    case (opcode)
      7'b0110011: return R_T;  // register-register ALU

      7'b0010011,  // ALU immediate
      7'b0000011,  // Loads
      7'b1100111:  // JALR
      return I_T;

      7'b0100011: return S_T;  // Stores
      7'b1100011: return B_T;  // Branches

      7'b0110111,  // LUI
      7'b0010111:  // AUIPC
      return U_T;

      7'b1101111: return J_T;  // JAL

      default: return INVALID_T;
    endcase
  endfunction

endpackage
