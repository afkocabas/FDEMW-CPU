package fdemw_pkg;

  parameter logic HIGH = 1'b1;
  parameter logic LOW = 1'b0;

  parameter int BYTE_WIDTH = 8;

  parameter int ADDR_WIDTH = 10;

  parameter int INST_WIDTH = 32;
  parameter int INST_BYTES = INST_WIDTH / BYTE_WIDTH;  // 4 bytes

  parameter int WORD_WIDTH = 32;
  parameter int WORD_BYTES = WORD_WIDTH / BYTE_WIDTH;  // 4 bytes
  parameter int BYTE_OFFSET_NBITS = $clog2(WORD_BYTES);  // 2 bits
  parameter int WORD_INDEX_NBITS = ADDR_WIDTH - BYTE_OFFSET_NBITS;  // 8 bits

  parameter int MEM_BYTES = 1 << ADDR_WIDTH;  // 2^10 bytes
  parameter int MEM_WORDS = MEM_BYTES / WORD_BYTES;  // 2^10 / 4 = 2^8 words

  parameter int GP_REG_WIDTH = WORD_WIDTH;
  parameter int GP_REG_BYTES = GP_REG_WIDTH / BYTE_WIDTH;

  parameter int REG_FILE_DEPTH = 32;
  parameter int REG_FILE_IDX_NBITS = $clog2(REG_FILE_DEPTH);

  // Adresss ________ __ -> If multiple of 4, it points to a word. A word is
  // WORD_BYTES bytes, which is currently 4. 4 bytes can be represented by
  // 2 bits. So the last two bits of the address are byte offset. The other
  // 8 bits are for indexing a word inside the memory.

  typedef struct packed {
    logic [WORD_INDEX_NBITS-1:0]  word_idx;
    logic [BYTE_OFFSET_NBITS-1:0] byte_offset;
  } addr_fields_t;

  typedef union packed {
    logic [ADDR_WIDTH - 1:0] raw;
    addr_fields_t fields;
  } addr_t;

  // Typedefinitions
  typedef logic [WORD_WIDTH - 1:0] word_t;
  typedef logic [7:0] byte_t;
  typedef logic [6:0] seg_t;
  typedef logic [GP_REG_WIDTH - 1:0] gp_reg_t;
  typedef gp_reg_t reg_file_t[REG_FILE_DEPTH-1:0];
  typedef logic [REG_FILE_IDX_NBITS - 1:0] reg_idx_t;

endpackage
