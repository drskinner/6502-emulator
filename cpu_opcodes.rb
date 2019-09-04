# This will be a long list but it has to be defined somewhere.

OPCODES = {
  0x00 => %w[BRK implied     1 7],
  0x18 => %w[CLC implied     1 2],
  0x38 => %w[SEC implied     1 2],
  0x58 => %w[CLI implied     1 2],
  0x78 => %w[SEI implied     1 2],
  0x88 => %w[DEY implied     1 2],
  0xa5 => %w[LDA zero_page   2 3],
  0xa9 => %w[LDA immediate   2 2],
  0xa0 => %w[LDY immediate   2 2],
  0xa1 => %w[LDA indirect_x  2 6],
  0xa2 => %w[LDX immediate   2 2],
  0xa4 => %w[LDY zero_page   2 3],
  0xa6 => %w[LDX zero_page   2 3],
  0xac => %w[LDY absolute    3 4],
  0xad => %w[LDA absolute    3 4],
  0xae => %w[LDX absolute    3 4],
  0xb1 => %w[LDA indirect_y  2 5],
  0xb4 => %w[LDY zero_page_x 2 4],
  0xb5 => %w[LDA zero_page_x 2 4],
  0xb6 => %w[LDX zero_page_y 2 4],
  0xb9 => %w[LDA absolute_y  3 4],
  0xbc => %w[LDY absolute_x  3 4],
  0xbd => %w[LDA absolute_x  3 4],
  0xbe => %w[LDX absolute_y  3 4],
  0xc6 => %w[DEC zero_page   2 5],
  0xc8 => %w[INY implied     1 2],
  0xca => %w[DEX implied     1 2],
  0xce => %w[DEC absolute    3 6],
  0xd6 => %w[DEC zero_page_x 2 6],
  0xd8 => %w[CLD implied     1 2],
  0xde => %w[DEC absolute_x  3 7],
  0xe6 => %w[INC zero_page   2 5],
  0xe8 => %w[INX implied     1 2],
  0xea => %w[NOP implied     1 2],
  0xee => %w[INC absolute    3 6],
  0xf6 => %w[INC zero_page_x 2 6],
  0xf8 => %w[SED implied     1 2],
  0xfe => %w[INC absolute_x  3 7]
}
