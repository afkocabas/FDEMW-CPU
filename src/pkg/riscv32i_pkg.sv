import fdemw_pkg::*;
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
    INST_INVALID
  } inst_format_e;

  typedef enum logic [3:0] {
    // R-type
    IK_R_ALU,

    // I-type
    IK_I_ALU,
    IK_LOAD,
    IK_JALR,

    // S-type
    IK_STORE,

    // B-type
    IK_BRANCH,

    // J-type
    IK_JAL,

    // U-type
    IK_LUI,
    IK_AUIPC,

    // Invalid
    IK_INVALID
  } inst_kind_e;

  typedef enum logic [3:0] {
    ADD,   // rs1 + rs2
    SUB,   // rs1 - rs2
    SLL,   // shift left logical
    SLT,   // signed less than
    SLTU,  // unsigned less than
    XOR,   // bitwise xor
    SRL,   // shift right logical
    SRA,   // shift right arithmetic
    OR,    // bitwise or
    AND,   // bitwise and

    PASS_B,   // for LUI
    PASS_A,   // sometimes useful
    ALU_NONE  // default / no-op / illegal
  } alu_op_t;

  typedef logic [INST_WIDTH-1:0] imm_t;

  typedef enum logic [1:0] {
    SRC1_RS1,
    SRC1_IMM,
    SRC1_ZERO
  } alu_src1_t;

  typedef enum logic {
    SRC2_RS2,
    SRC2_IMM
  } alu_src2_t;

  typedef enum logic [1:0] {
    WB_ALU,
    WB_MEM,
    WB_PC4
  } wb_sel_t;

  typedef enum logic [2:0] {
    BR_NONE,
    BR_BEQ,
    BR_BNE,
    BR_BLT,
    BR_BGE,
    BR_BLTU,
    BR_BGEU
  } branch_type_t;

  function automatic inst_format_e get_inst_format(inst_t inst);
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

      default: return INST_INVALID;
    endcase
  endfunction

  function automatic alu_op_t get_alu_op_r_t(logic [6:0] funct7, logic [2:0] funct3);
    unique case ({
      funct7, funct3
    })
      10'b0000000_000: return ADD;
      10'b0100000_000: return SUB;

      10'b0000000_001: return SLL;

      10'b0000000_010: return SLT;
      10'b0000000_011: return SLTU;

      10'b0000000_100: return XOR;

      10'b0000000_101: return SRL;
      10'b0100000_101: return SRA;

      10'b0000000_110: return OR;
      10'b0000000_111: return AND;

      default: return ALU_NONE;

    endcase
  endfunction

  function automatic inst_kind_e get_inst_kind(inst_t inst);
    logic [6:0] opcode;
    opcode = inst[6:0];

    unique case (opcode)
      7'b0110011: return IK_R_ALU;
      7'b0010011: return IK_I_ALU;
      7'b0000011: return IK_LOAD;
      7'b0100011: return IK_STORE;
      7'b1100011: return IK_BRANCH;
      7'b1101111: return IK_JAL;
      7'b1100111: return IK_JALR;
      7'b0110111: return IK_LUI;
      7'b0010111: return IK_AUIPC;
      default:    return IK_INVALID;
    endcase
  endfunction



  // ALU operation decoding by instruction format

  function automatic alu_op_t get_alu_op_i_t(logic [6:0] funct7, logic [2:0] funct3);
    unique case (funct3)

      3'b000: return ADD;

      3'b010: return SLT;
      3'b011: return SLTU;

      3'b100: return XOR;
      3'b110: return OR;
      3'b111: return AND;

      3'b001: return SLL;

      3'b101: begin
        if (funct7 == 7'b0000000) return SRL;  // srli
        else if (funct7 == 7'b0100000) return SRA;  // srai
        else return ALU_NONE;
      end

      default: return ALU_NONE;

    endcase
  endfunction


  function automatic alu_op_t get_alu_op_s_t(logic [2:0] funct3);
    unique case (funct3)

      3'b000: return ADD;  // sb
      3'b001: return ADD;  // sh
      3'b010: return ADD;  // sw

      default: return ALU_NONE;

    endcase
  endfunction


  // -------------------------------- Instruction Validity Checks -----------------------------

  function automatic logic is_valid_i_t(inst_kind_e kind, logic [6:0] funct7, logic [2:0] funct3);
    unique case (kind)

      IK_I_ALU: begin
        return (get_alu_op_i_t(funct7, funct3) != ALU_NONE);
      end

      IK_LOAD: begin
        unique case (funct3)
          3'b000, 3'b001, 3'b010, 3'b100, 3'b101: return 1'b1;
          default: return 1'b0;
        endcase
      end

      IK_JALR: begin
        return (funct3 == 3'b000);
      end

      default: return 1'b0;

    endcase
  endfunction

  function automatic logic is_valid_s_t(logic [2:0] funct3);
    unique case (funct3)
      3'b000, 3'b001, 3'b010: return 1'b1;
      default: return 1'b0;
    endcase
  endfunction

endpackage
