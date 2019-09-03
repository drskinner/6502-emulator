OPCODES = {
  0x00 => %w[BRK implied     1 7],
  0x18 => %w[CLC implied     1 2],
  0x38 => %w[SEC implied     1 2],
  0x58 => %w[CLI implied     1 2],
  0x78 => %w[SEI implied     1 2],
  0x88 => %w[DEY implied     1 2],
  0xa5 => %w[LDA zero_page   2 3],
  0xa9 => %w[LDA immediate   2 2],
  0xad => %w[LDA absolute    3 4],
  0xb5 => %w[LDA zero_page_x 2 4],
  0xb9 => %w[LDA absolute_y  3 4],
  0xbd => %w[LDA absolute_x  3 4],
  0xc6 => %w[DEC zero_page   2 5],
  0xc8 => %w[INY implied     1 2],
  0xca => %w[DEX implied     1 2],
  0xce => %w[DEC absolute    3 6],
  0xd6 => %w[DEC zero_page_x 2 6],
  0xd8 => %w[CLD implied     1 2],
  0xde => %w[DEC absolute_x  3 7],
  0xe8 => %w[INX implied     1 2],
  0xea => %w[NOP implied     1 2],
  0Xf8 => %w[SED implied     1 2]
}
