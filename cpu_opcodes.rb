# This will be a long list but it has to be defined somewhere.

OPCODES = {
  0x00 => %w[BRK implied     1 7],
  0x02 => %w[HLT implied     1 0],
  0x08 => %w[PHP implied     1 3],

  0x18 => %w[CLC implied     1 2],

  0x28 => %w[PLP implied     1 4],

  0x38 => %w[SEC implied     1 2],

  0x48 => %w[PHA implied     1 3],
  0x4c => %w[JMP absolute    3 3],

  0x58 => %w[CLI implied     1 2],

  0x68 => %w[PLA implied     1 4],
  0x6c => %w[JMP indirect    3 5],

  0x78 => %w[SEI implied     1 2],

  0x81 => %w[STA indirect_x  2 6],
  0x84 => %w[STY zero_page   2 3],
  0x85 => %w[STA zero_page   2 3],
  0x86 => %w[STX zero_page   2 3],
  0x88 => %w[DEY implied     1 2],
  0x8a => %w[TXA implied     1 2],
  0x8c => %w[STY absolute    3 4],
  0x8d => %w[STA absolute    3 4],
  0x8e => %w[STX absolute    3 4],

  0x91 => %w[STA indirect_y  2 6],
  0x94 => %w[STY zero_page_x 2 3],
  0x95 => %w[STA zero_page_x 2 4],
  0x96 => %w[STX zero_page_y 2 4],
  0x98 => %w[TYA implied     1 2],
  0x99 => %w[STA absolute_y  3 5],
  0x9a => %w[TXS implied     1 2],
  0x9d => %w[STA absolute_x  3 5],

  0xa5 => %w[LDA zero_page   2 3],
  0xa9 => %w[LDA immediate   2 2],
  0xa0 => %w[LDY immediate   2 2],
  0xa1 => %w[LDA indirect_x  2 6],
  0xa2 => %w[LDX immediate   2 2],
  0xa4 => %w[LDY zero_page   2 3],
  0xa6 => %w[LDX zero_page   2 3],
  0xa8 => %w[TAY implied     1 2],
  0xaa => %w[TAX implied     1 2],
  0xac => %w[LDY absolute    3 4],
  0xad => %w[LDA absolute    3 4],
  0xae => %w[LDX absolute    3 4],

  0xb1 => %w[LDA indirect_y  2 5],
  0xb4 => %w[LDY zero_page_x 2 4],
  0xb5 => %w[LDA zero_page_x 2 4],
  0xb6 => %w[LDX zero_page_y 2 4],
  0xb9 => %w[LDA absolute_y  3 4],
  0xba => %w[TSX implied     1 2],
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
