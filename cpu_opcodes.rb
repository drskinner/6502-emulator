OPCODES = {
  0x00 => %w[BRK implied   1 7],
  0x18 => %w[CLC implied   1 2],
  0x38 => %w[SEC implied   1 2],
  0x58 => %w[CLI implied   1 2],
  0x78 => %w[SEI implied   1 2],
  0xa5 => %w[LDA zero_page 2 3],
  0xa9 => %w[LDA immediate 2 2],
  0xad => %w[LDA absolute  3 4],
  0xd8 => %w[CLD implied   1 2],
  0xea => %w[NOP implied   1 2],
  0Xf8 => %w[SED implied   1 2]
}
