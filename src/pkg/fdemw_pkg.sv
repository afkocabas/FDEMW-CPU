package fdemw_pkg;

  parameter int BYTE_WIDTH = 8;

  parameter int ADDR_WIDTH = 8;

  parameter int WORD_BYTES = 4;
  parameter int WORD_WIDTH = WORD_BYTES * 8;

  parameter int MEM_BYTES = 1 << ADDR_WIDTH;
  parameter int MEM_WORDS = MEM_BYTES / WORD_BYTES;


  // Typedefinitions
  typedef logic [ADDR_WIDTH - 1:0] addr_t;
  typedef logic [WORD_WIDTH - 1:0] word_t;
  typedef logic [7:0] byte_t;
  typedef logic [6:0] seg_t;

endpackage
