require 'test/unit'
require './cpu.rb'

#
# Copy some 6502-executable bytes with load_memory
# and test assertions at defined breakpoints.
#
class MyTest < Test::Unit::TestCase
  def setup
    @cpu = Cpu.new
    @base_address = 0xc000
  end

  # def teardown
  # end

  def load_memory(bytes)
    bytes.each_with_index do |value, index|
      @cpu.write_ram(address: (@base_address + index) & 0xffff, data: value.to_i(16))
    end
  end

  # C000 AND $c080
  # C002 BRK
  def test_AND_absolute
    load_memory %w[2d 80 c0 00]

    @cpu.accumulator = 0xff
    @cpu.write_ram(address: 0xc080, data: 0xf0)
    @cpu.execute(address: @base_address)
    assert_equal(0xf0, @cpu.accumulator)
  end

  # C000 AND $c080,x
  # C002 BRK
  def test_AND_absolute_x
    load_memory %w[3d 80 c0 00]

    @cpu.accumulator = 0xff
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0xc090, data: 0x0f)
    @cpu.execute(address: @base_address)
    assert_equal(0x0f, @cpu.accumulator)
  end

  # C000 AND $c080,y
  # C002 BRK
  def test_AND_absolute_y
    load_memory %w[39 80 c0 00]

    @cpu.accumulator = 0xff
    @cpu.y_register = 0x20
    @cpu.write_ram(address: 0xc0a0, data: 0x0f)
    @cpu.execute(address: @base_address)
    assert_equal(0x0f, @cpu.accumulator)
  end

  # C000 AND #$03
  # C002 BRK
  # C003 AND #$F0
  # C005 BRK
  # C006 AND #$81
  # C008 BRK
  def test_AND_immediate
    load_memory %w[29 03 00 29 f0 00 29 81 00]

    @cpu.accumulator = 0x06
    @cpu.execute(address: @base_address)
    assert_equal(0x02, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.accumulator = 0x0f
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.accumulator = 0x82
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x80, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 AND ($F0,X)
  # C002 BRK
  def test_AND_indirect_x
    load_memory %w[21 f0 00]

    @cpu.accumulator = 0xff
    @cpu.x_register = 0x0e
    # $00fe-$00ff points to $c0f0
    @cpu.write_ram(address: 0x00fe, data: 0xf0)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc0f0, data: 0x0f)
    @cpu.execute(address: @base_address)
    assert_equal(0x0f, @cpu.accumulator)
  end

  # C000 AND ($FE),Y
  # C002 BRK
  #
  def test_AND_indirect_y
    load_memory %w[31 fe 00]

    # $00fe-$00ff points to $c0f1
    @cpu.accumulator = 0xff
    @cpu.y_register = 0x0f
    @cpu.write_ram(address: 0x00fe, data: 0xf1)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc100, data: 0x0f)
    @cpu.execute(address: @base_address)
    assert_equal(0x0f, @cpu.accumulator)
  end

  # C000 AND $80
  # C002 BRK
  def test_AND_zero_page
    load_memory %w[25 80 00]

    @cpu.accumulator = 0xff
    @cpu.write_ram(address: 0x0080, data: 0xf0)
    @cpu.execute(address: @base_address)
    assert_equal(0xf0, @cpu.accumulator)
  end

  # C000 AND $80,x
  # C002 BRK
  def test_AND_zero_page_x
    load_memory %w[35 80 00]

    @cpu.accumulator = 0xff
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0x0090, data: 0xf0)
    @cpu.execute(address: @base_address)
    assert_equal(0xf0, @cpu.accumulator)
  end

  # C000 BRK
  def test_BRK
    load_memory %w[00]
    
    @cpu.clear_flag(SR_BREAK)
    @cpu.execute(address: @base_address)
    assert_equal(true, @cpu.set?(SR_BREAK))
    assert_equal(@base_address + 0x01, @cpu.program_counter)
  end

  # C000 CLC
  # C001 BRK
  def test_CLC
    load_memory %w[18 00]

    @cpu.set_flag(SR_CARRY)
    @cpu.execute(address: @base_address)
    assert_equal(false, @cpu.set?(SR_CARRY))
  end

  # C000 CLD
  # C001 BRK
  def test_CLD
    load_memory %w[d8 00]

    @cpu.set_flag(SR_DECIMAL)
    @cpu.execute(address: @base_address)
    assert_equal(false, @cpu.set?(SR_DECIMAL))
  end

  # C000 CLI
  # C001 BRK
  def test_CLI
    load_memory %w[58 00]

    @cpu.set_flag(SR_INTERRUPT)
    @cpu.execute(address: @base_address)
    assert_equal(false, @cpu.set?(SR_INTERRUPT))
  end

  # C000 CLV
  # C001 BRK
  def test_CLV
    load_memory %w[B8 00]

    @cpu.set_flag(SR_OVERFLOW)
    @cpu.execute(address: @base_address)
    assert_equal(false, @cpu.set?(SR_OVERFLOW))
  end

  # C000 DEC $C010 ; absolute
  # C003 BRK
  def test_DEC_absolute
    load_memory %w[ce 10 c0 00]

    @cpu.write_ram(address: 0xc010, data: 0xc0)
    @cpu.execute(address: @base_address)
    assert_equal(0xbf, @cpu.read_ram(address: 0xc010))
  end

  # C000 DEC $C020,X
  # C003 BRK
  # C004 DEC $FFFF,X
  # BRK
  def test_DEC_absolute_x
    load_memory %w[de 20 c0 00 de ff ff 00]

    @cpu.write_ram(address: 0xc023, data: 0xd0)
    @cpu.x_register = 0x03
    @cpu.execute(address: @base_address)
    assert_equal(0xcf, @cpu.read_ram(address: 0xc023))

    # test wrap-around from memory top to zero page
    @cpu.write_ram(address: 0x0002, data: 0xe0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xdf, @cpu.read_ram(address: 0x0002))
  end

  # C000 DEC $80 ; zero page, Z flag
  # C002 BRK
  # C003 DEC $80 ; N flag
  # C005 BRK
  def test_DEC_zero_page
    load_memory %w[c6 80 00 c6 80 00]

    @cpu.write_ram(address: 0x0080, data: 0x01)
    @cpu.execute(address: @base_address)
    assert_equal(0x00, @cpu.read_ram(address: 0x0080))
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.read_ram(address: 0x0080))
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 DEC $80,X
  # C002 BRK
  # C003 DEC $80,X
  # C005 BRK
  def test_DEC_zero_page_x
    load_memory %w[d6 80 00 d6 80 00]

    @cpu.x_register = 0x0f
    @cpu.write_ram(address: 0x008f, data: 0xc0)
    @cpu.execute(address: @base_address)
    assert_equal(0xbf, @cpu.read_ram(address: 0x008f))

    # test zero-page wrap-around
    @cpu.x_register = 0xff
    @cpu.write_ram(address: 0x007f, data: 0xd0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xcf, @cpu.read_ram(address: 0x007f))
  end

  # C000 DEX
  # C001 BRK
  # C002 DEX
  # C003 BRK
  def test_DEX
    load_memory %w[ca 00 ca 00]

    @cpu.x_register = 0x01
    @cpu.execute(address: @base_address)
    assert_equal(0x00, @cpu.x_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.x_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 DEY
  # C001 BRK
  # C002 DEY
  # C003 BRK
  def test_DEY
    load_memory %w[88 00 88 00]

    @cpu.y_register = 0x01
    @cpu.execute(address: @base_address)
    assert_equal(0x00, @cpu.y_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.y_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 EOR $c080
  # C002 BRK
  def test_EOR_absolute
    load_memory %w[4d 80 c0 00]

    @cpu.accumulator = 0b0110_0110
    @cpu.write_ram(address: 0xc080, data: 0b0011_1100)
    @cpu.execute(address: @base_address)
    assert_equal(0b0101_1010, @cpu.accumulator)
  end

  # C000 EOR $c080,x
  # C002 BRK
  def test_EOR_absolute_x
    load_memory %w[5d 80 c0 00]

    @cpu.accumulator = 0b0110_0110
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0xc090, data: 0b0011_1100)
    @cpu.execute(address: @base_address)
    assert_equal(0b0101_1010, @cpu.accumulator)
  end

  # C000 EOR $c080,y
  # C002 BRK
  def test_EOR_absolute_y
    load_memory %w[59 80 c0 00]

    @cpu.accumulator = 0b0110_0110
    @cpu.y_register = 0x20
    @cpu.write_ram(address: 0xc0a0, data: 0b0011_1100)
    @cpu.execute(address: @base_address)
    assert_equal(0b0101_1010, @cpu.accumulator)
  end

  # C000 EOR #$3C ; %0011 1100
  # C002 BRK
  # C003 EOR #$66 ; %0110 0110
  # C005 BRK
  # C006 EOR #$01
  # C008 BRK
  def test_EOR_immediate
    load_memory %w[49 3c 00 49 66 00 49 01 00]

    # 0110_0110 ^ 0011_1100 == 0101_1010
    @cpu.accumulator = 0b0110_0110
    @cpu.execute(address: @base_address)
    assert_equal(0x5a, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.accumulator = 0b0110_0110
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.accumulator = 0b1000_0000
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x81, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 EOR ($F0,X)
  # C002 BRK
  def test_EOR_indirect_x
    load_memory %w[41 f0 00]

    @cpu.accumulator = 0b0110_0110
    @cpu.x_register = 0x0e
    # $00fe-$00ff points to $c0f0
    @cpu.write_ram(address: 0x00fe, data: 0xf0)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc0f0, data: 0b0011_1100)
    @cpu.execute(address: @base_address)
    assert_equal(0b0101_1010, @cpu.accumulator)
  end

  # C000 EOR ($FE),Y
  # C002 BRK
  #
  def test_EOR_indirect_y
    load_memory %w[51 fe 00]

    # $00fe-$00ff points to $c0f1
    @cpu.accumulator = 0b0110_0110
    @cpu.y_register = 0x0f
    @cpu.write_ram(address: 0x00fe, data: 0xf1)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc100, data: 0b0011_1100)
    @cpu.execute(address: @base_address)
    assert_equal(0b0101_1010, @cpu.accumulator)
  end

  # C000 EOR $80
  # C002 BRK
  def test_EOR_zero_page
    load_memory %w[45 80 00]

    @cpu.accumulator = 0b0110_0110
    @cpu.write_ram(address: 0x0080, data: 0b0011_1100)
    @cpu.execute(address: @base_address)
    assert_equal(0b0101_1010, @cpu.accumulator)
  end

  # C000 EOR $80,x
  # C002 BRK
  def test_EOR_zero_page_x
    load_memory %w[55 80 00]

    @cpu.accumulator = 0b0101_0110
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0x0090, data: 0b1010_0110)
    @cpu.execute(address: @base_address)
    assert_equal(0b1111_0000, @cpu.accumulator)
  end

  # C000 INC $C010 ; absolute
  # C003 BRK
  def test_INC_absolute
    load_memory %w[ee 10 c0 00]

    @cpu.write_ram(address: 0xc010, data: 0xa0)
    @cpu.execute(address: @base_address)
    assert_equal(0xa1, @cpu.read_ram(address: 0xc010))
  end

  # C000 INC $C020,X
  # C003 BRK
  # C004 INC $FFFF,X
  # BRK
  def test_INC_absolute_x
    load_memory %w[fe 20 c0 00 fe ff ff 00]

    @cpu.write_ram(address: 0xc023, data: 0xd0)
    @cpu.x_register = 0x03
    @cpu.execute(address: @base_address)
    assert_equal(0xd1, @cpu.read_ram(address: 0xc023))

    # test wrap-around from memory top to zero page
    @cpu.write_ram(address: 0x0002, data: 0xe0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xe1, @cpu.read_ram(address: 0x0002))
  end

  # C000 INC $80 ; zero page, N flag
  # C002 BRK
  # C003 INC $80 ; Z flag
  # C005 BRK
  def test_INC_zero_page
    load_memory %w[e6 80 00 e6 80 00]

    @cpu.write_ram(address: 0x0080, data: 0xfe)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.read_ram(address: 0x0080))
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.read_ram(address: 0x0080))
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))
  end

  # C000 INC $80,X
  # C002 BRK
  # C003 INC $80,X
  # C005 BRK
  def test_INC_zero_page_x
    load_memory %w[f6 80 00 f6 80 00]

    @cpu.x_register = 0x0f
    @cpu.write_ram(address: 0x008f, data: 0xb0)
    @cpu.execute(address: @base_address)
    assert_equal(0xb1, @cpu.read_ram(address: 0x008f))

    # test zero-page wrap-around
    @cpu.x_register = 0xff
    @cpu.write_ram(address: 0x007f, data: 0xc0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xc1, @cpu.read_ram(address: 0x007f))
  end

  # C000 INX
  # C001 BRK
  # C002 INX
  # C003 BRK
  def test_INX
    load_memory %w[e8 00 e8 00]

    @cpu.x_register = 0xfe
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.x_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.x_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))
  end

  # C000 INY
  # C001 BRK
  # C002 INY
  # C003 BRK
  def test_INY
    load_memory %w[c8 00 c8 00]

    @cpu.y_register = 0xfe
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.y_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.y_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))
  end

  # C000 JMP $C006
  # C003 BRK
  # C004 NOP
  # C005 NOP
  # C006 HLT
  def test_JMP_absolute
    load_memory %w[4c 06 c0 00 ea ea 02]

    @cpu.execute(address: @base_address)
    assert_equal(0xc006, @cpu.program_counter)
  end

  # C000 JMP ($1234)
  # C003 BRK
  # C004 NOP
  # C005 HLT
  # C006 JMP ($12FF)
  # C009 BRK
  # C00A NOP
  # C00B HLT
  def test_JMP_indirect
    load_memory %w[6c 34 12 00 ea 02 6c ff 12 00 ea 02]

    @cpu.write_ram(address: 0x1234, data: 0x05)
    @cpu.write_ram(address: 0x1235, data: 0xc0)
    @cpu.execute(address: @base_address)
    assert_equal(0xc005, @cpu.program_counter)

    # test for the JMP page-boundary bug
    @cpu.program_counter = 0xc006
    @cpu.write_ram(address: 0x12ff, data: 0x0b)
    @cpu.write_ram(address: 0x1200, data: 0xc0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xc00b, @cpu.program_counter)
  end

  # C000 LDA $C008   ; absolute
  # C003 BRK
  def test_LDA_absolute
    load_memory %w[ad 08 c0 00]

      # $c008 = #$a9
      @cpu.write_ram(address: 0xc008, data: 0xa9)
      @cpu.execute(address: @base_address)
      assert_equal(0xa9, @cpu.accumulator)
  end

  # C000 LDA $c000,x ; absolute,x
  # C003 BRK
  def test_LDA_absolute_x
    load_memory %w[bd 00 c0 00]

    # $c010 = #$b4
    @cpu.write_ram(address: 0xc010, data: 0xb4)
    @cpu.x_register = 0x10
    @cpu.execute(address: @base_address)
    assert_equal(0xb4, @cpu.accumulator)
  end

  # C000 LDA $c000,y ; absolute,y
  # C003 BRK
  def test_LDA_absoulte_y
    load_memory %w[b9 00 c0 00]

    # $c00c = #$ad
    @cpu.write_ram(address: 0xc00c, data: 0xad)
    @cpu.y_register = 0x0c
    @cpu.execute(address: @base_address)
    assert_equal(0xad, @cpu.accumulator)
  end

  # C000 LDA #$40    ; immediate
  # C002 BRK
  # C003 LDA #$00    ; test Z flag
  # C005 BRK
  # C006 LDA #$FF    ; test N flag
  # C008 BRK
  def test_LDA_immediate
    load_memory %w[a9 40 00 a9 00 00 a9 ff 00]

    # A = #$40
    @cpu.execute(address: @base_address)
    assert_equal(0x40, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # A = #$00 ; test Z flag
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # A = #$ff ; test N flag
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xFF, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 LDA ($F0,X)
  # C002 BRK
  # C003 LDA ($F0,X)
  # C005 BRK
  #
  # This address mode is why I write unit tests. Yeesh.
  #
  def test_LDA_indirect_x
    load_memory %w[a1 f0 00 a1 f0 00]

    # $00fe-$00ff points to $c0f0
    @cpu.write_ram(address: 0x00fe, data: 0xf0)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc0f0, data: 0xee)
    @cpu.x_register = 0x0e
    @cpu.execute(address: @base_address)
    assert_equal(0xee, @cpu.accumulator)

    # test page-wrapping
    @cpu.write_ram(address: 0x0002, data: 0xf0)
    @cpu.write_ram(address: 0x0003, data: 0xc1)
    @cpu.write_ram(address: 0xc1f0, data: 0xed)
    @cpu.x_register = 0x12
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xed, @cpu.accumulator)
  end

  # C000 LDA ($FE),Y
  # C002 BRK
  # C003 LDA ($FE),Y
  # C005 BRK
  #
  # This address mode is also why I write unit tests.
  #
  def test_LDA_indirect_y
    load_memory %w[b1 fe 00 b1 fe 00]

    # $00fe-$00ff points to $c0f0
    @cpu.write_ram(address: 0x00fe, data: 0xf0)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc0ff, data: 0xee)
    @cpu.y_register = 0x0f
    @cpu.execute(address: @base_address)
    assert_equal(0xee, @cpu.accumulator)

    # test page-crossing
    @cpu.write_ram(address: 0xc101, data: 0xed)
    @cpu.y_register = 0x11
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xed, @cpu.accumulator)
  end

  # C000 LDA $80     ; zero-page
  # C002 BRK
  def test_LDA_zero_page
    load_memory %w[a5 80 00]

    # $0080 = #$ff
    @cpu.write_ram(address: 0x0080, data: 0xff)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 LDA $70,x   ; zero-page,x
  # C002 BRK
  def test_LDA_zero_page_x
    load_memory %w[b5 70 00]

    # $0080 = #$fe
    @cpu.write_ram(address: 0x0080, data: 0xfe)
    @cpu.x_register = 0x10
    @cpu.execute(address: @base_address)
    assert_equal(0xfe, @cpu.accumulator)
  end

  # C000 LDX $C008   ; absolute
  # C003 BRK
  def test_LDX_absolute
    load_memory %w[ae 08 c0 00]

      # $c008 = #$a9
      @cpu.write_ram(address: 0xc008, data: 0xa9)
      @cpu.execute(address: @base_address)
      assert_equal(0xa9, @cpu.x_register)
  end

  # C000 LDX $c000,y ; absolute,y
  # C003 BRK
  def test_LDX_absolute_y
    load_memory %w[be 00 c0 00]

    # $c010 = #$b3
    @cpu.write_ram(address: 0xc010, data: 0xb3)
    @cpu.y_register = 0x10
    @cpu.execute(address: @base_address)
    assert_equal(0xb3, @cpu.x_register)
  end

  # C000 LDX #$40    ; immediate
  # C002 BRK
  # C003 LDX #$00    ; test Z flag
  # C005 BRK
  # C006 LDX #$FF    ; test N flag
  # C008 BRK
  def test_LDX_immediate
    load_memory %w[a2 40 00 a2 00 00 a2 ff 00]

    # X = #$40
    @cpu.execute(address: @base_address)
    assert_equal(0x40, @cpu.x_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # X = #$00 ; test Z flag
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.x_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # X = #$ff ; test N flag
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xFF, @cpu.x_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 LDX $80     ; zero-page
  # C002 BRK
  def test_LDX_zero_page
    load_memory %w[a6 80 00]

    # $0080 = #$ff
    @cpu.write_ram(address: 0x0080, data: 0xfc)
    @cpu.execute(address: @base_address)
    assert_equal(0xfc, @cpu.x_register)
  end

  # C000 LDX $70,y   ; zero-page,y
  # C002 BRK
  def test_LDX_zero_page_y
    load_memory %w[b6 70 00]

    # $0080 = #$fd
    @cpu.write_ram(address: 0x0080, data: 0xfd)
    @cpu.y_register = 0x10
    @cpu.execute(address: @base_address)
    assert_equal(0xfd, @cpu.x_register)
  end

  # C000 LDY $C008   ; absolute
  # C003 BRK
  def test_LDY_absolute
    load_memory %w[ac 08 c0 00]

      # $c008 = #$a8
      @cpu.write_ram(address: 0xc008, data: 0xa8)
      @cpu.execute(address: @base_address)
      assert_equal(0xa8, @cpu.y_register)
  end

  # C000 LDY $c000,x ; absolute,x
  # C003 BRK
  def test_LDY_absolute_x
    load_memory %w[bc 00 c0 00]

    # $c010 = #$b2
    @cpu.write_ram(address: 0xc010, data: 0xb2)
    @cpu.x_register = 0x10
    @cpu.execute(address: @base_address)
    assert_equal(0xb2, @cpu.y_register)
  end

  # C000 LDY #$40    ; immediate
  # C002 BRK
  # C003 LDY #$00    ; test Z flag
  # C005 BRK
  # C006 LDY #$FF    ; test N flag
  # C008 BRK
  def test_LDY_immediate
    load_memory %w[a0 40 00 a0 00 00 a0 ff 00]

    # X = #$40
    @cpu.execute(address: @base_address)
    assert_equal(0x40, @cpu.y_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # X = #$00 ; test Z flag
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.y_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # X = #$ff ; test N flag
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xFF, @cpu.y_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 LDY $80     ; zero-page
  # C002 BRK
  def test_LDY_zero_page
    load_memory %w[a4 80 00]

    # $0080 = #$fd
    @cpu.write_ram(address: 0x0080, data: 0xfd)
    @cpu.execute(address: @base_address)
    assert_equal(0xfd, @cpu.y_register)
  end

  # C000 LDX $70,y   ; zero-page,y
  # C002 BRK
  def test_LDY_zero_page_x
    load_memory %w[b4 70 00]

    # $0080 = #$fa
    @cpu.write_ram(address: 0x0080, data: 0xfa)
    @cpu.x_register = 0x10
    @cpu.execute(address: @base_address)
    assert_equal(0xfa, @cpu.y_register)
  end

  # C000 NOP
  # C001 BRK
  def test_NOP
    load_memory %w[ea 00]
    
    @cpu.clear_flag(SR_BREAK)
    @cpu.execute(address: @base_address)
    assert_equal(true, @cpu.set?(SR_BREAK))
    assert_equal(@base_address + 0x02, @cpu.program_counter)
  end

  # C000 ORA $c080
  # C002 BRK
  def test_ORA_absolute
    load_memory %w[0d 80 c0 00]

    @cpu.accumulator = 0xf0
    @cpu.write_ram(address: 0xc080, data: 0x0f)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 ORA $c080,x
  # C002 BRK
  def test_ORA_absolute_x
    load_memory %w[1d 80 c0 00]

    @cpu.accumulator = 0xf0
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0xc090, data: 0x0f)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 ORA $c080,y
  # C002 BRK
  def test_ORA_absolute_y
    load_memory %w[19 80 c0 00]

    @cpu.accumulator = 0xf0
    @cpu.y_register = 0x20
    @cpu.write_ram(address: 0xc0a0, data: 0x0f)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 ORA #$0C
  # C002 BRK
  # C003 ORA #$00
  # C005 BRK
  # C006 ORA #$80
  # C008 BRK
  def test_ORA_immediate
    load_memory %w[09 0c 00 09 00 00 09 80 00]

    @cpu.accumulator = 0x03
    @cpu.execute(address: @base_address)
    assert_equal(0x0f, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.accumulator = 0x00
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.accumulator = 0x01
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x81, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 ORA ($F0,X)
  # C002 BRK
  def test_ORA_indirect_x
    load_memory %w[01 f0 00]

    @cpu.accumulator = 0x0f
    @cpu.x_register = 0x0e
    # $00fe-$00ff points to $c0f0
    @cpu.write_ram(address: 0x00fe, data: 0xf0)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc0f0, data: 0xf0)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 ORA ($FE),Y
  # C002 BRK
  #
  def test_ORA_indirect_y
    load_memory %w[11 fe 00]

    # $00fe-$00ff points to $c0f1
    @cpu.accumulator = 0x0f
    @cpu.y_register = 0x0f
    @cpu.write_ram(address: 0x00fe, data: 0xf1)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc100, data: 0xf0)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 ORA $80
  # C002 BRK
  def test_ORA_zero_page
    load_memory %w[05 80 00]

    @cpu.accumulator = 0x0f
    @cpu.write_ram(address: 0x0080, data: 0xf0)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 ORA $80,x
  # C002 BRK
  def test_ORA_zero_page_x
    load_memory %w[15 80 00]

    @cpu.accumulator = 0x0f
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0x0090, data: 0xf0)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.accumulator)
  end

  # C000 PHA
  # C001 BRK
  # C002 PHA
  # C003 BRK
  def test_PHA
    load_memory %w[48 00 48 00]

    @cpu.stack_pointer = 0xff
    @cpu.accumulator = 0xac
    @cpu.execute(address: @base_address)
    assert_equal(0xfe, @cpu.stack_pointer)
    assert_equal(0xac, @cpu.read_ram(address: 0x01ff))

    # test stack overflow
    @cpu.stack_pointer = 0x00
    @cpu.accumulator = 0xac
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.stack_pointer)
    assert_equal(0xac, @cpu.read_ram(address: 0x0100))
  end

  # C000 PHP
  # C001 BRK
  def test_PHP
    load_memory %w[08 00]

    @cpu.stack_pointer = 0xff
    @cpu.status_register = 0xbd
    @cpu.execute(address: @base_address)
    assert_equal(0xfe, @cpu.stack_pointer)
    assert_equal(0xbd, @cpu.read_ram(address: 0x01ff))
  end

  # C000 PLA
  # C001 BRK
  # C002 PLA
  # C003 BRK
  # C004 PLA
  # C005 BRK
  def test_PLA
    load_memory %w[68 00 68 00 68 00]

    @cpu.accumulator = 0x00
    @cpu.stack_pointer = 0xfd
    @cpu.write_ram(address: 0x01fe, data: 0x31)
    @cpu.write_ram(address: 0x01ff, data: 0x80)
    @cpu.write_ram(address: 0x0100, data: 0x00)

    @cpu.execute(address: @base_address)
    assert_equal(0xfe, @cpu.stack_pointer)
    assert_equal(0x31, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # N flag
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.stack_pointer)
    assert_equal(0x80, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))

    # Z flag; overflow
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.stack_pointer)
    assert_equal(0x00, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))
  end

  # C000 PLP
  # C001 HLT ; BRK affects status flags!
  def test_PLP
    load_memory %w[28 02]

    @cpu.status_register = 0x00
    @cpu.stack_pointer = 0xfe
    @cpu.write_ram(address: 0x01ff, data: 0xee)
    @cpu.execute(address: @base_address)
    assert_equal(0xff, @cpu.stack_pointer)
    assert_equal(0xee, @cpu.status_register)
  end

  # C000 SEC
  # C001 BRK
  def test_SEC
    load_memory %w[38 00]

    @cpu.clear_flag(SR_CARRY)
    @cpu.execute(address: @base_address)
    assert_equal(true, @cpu.set?(SR_CARRY))
  end

  # C000 SED
  # C001 BRK
  def test_SED
    load_memory %w[f8 00]

    @cpu.clear_flag(SR_DECIMAL)
    @cpu.execute(address: @base_address)
    assert_equal(true, @cpu.set?(SR_DECIMAL))
  end

  # C000 SEI
  # C001 BRK
  def test_SEI
    load_memory %w[78 00]

    @cpu.clear_flag(SR_INTERRUPT)
    @cpu.execute(address: @base_address)
    assert_equal(true, @cpu.set?(SR_INTERRUPT))
  end

  # C000 STA $C201
  # C003 BRK
  def test_STA_absolute
    load_memory %w[8d 01 c2 00]

    @cpu.accumulator = 0x6f
    @cpu.write_ram(address: 0xc201, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0xc201))
    @cpu.execute(address: @base_address)
    assert_equal(0x6f, @cpu.read_ram(address: 0xc201))
  end

  # C000 STA $C201,x
  # C003 BRK
  def test_STA_absolute_x
    load_memory %w[9d 01 c2 00]

    @cpu.accumulator = 0x6e
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0xc211, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0xc211))
    @cpu.execute(address: @base_address)
    assert_equal(0x6e, @cpu.read_ram(address: 0xc211))
  end

  # C000 STA $C201,y
  # C003 BRK
  def test_STA_absolute_y
    load_memory %w[99 01 c2 00]

    @cpu.accumulator = 0x6d
    @cpu.y_register = 0x11
    @cpu.write_ram(address: 0xc212, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0xc212))
    @cpu.execute(address: @base_address)
    assert_equal(0x6d, @cpu.read_ram(address: 0xc212))
  end

  # C000 STA ($F0,X)
  # C002 BRK
  #
  def test_STA_indirect_x
    load_memory %w[81 f0 00]

    # $00fe-$00ff points to $c0f1
    @cpu.accumulator = 0x6c
    @cpu.x_register = 0x0e
    @cpu.write_ram(address: 0x00fe, data: 0xf1)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc0f1, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0xc0f1))

    @cpu.execute(address: @base_address)
    assert_equal(0x6c, @cpu.read_ram(address: 0xc0f1))
  end

  # C000 STA ($FE),Y
  # C002 BRK
  #
  def test_STA_indirect_y
    load_memory %w[91 fe 00]

    # $00fe-$00ff points to $c0f1
    @cpu.accumulator = 0x6b
    @cpu.y_register = 0x0f
    @cpu.write_ram(address: 0x00fe, data: 0xf1)
    @cpu.write_ram(address: 0x00ff, data: 0xc0)
    @cpu.write_ram(address: 0xc100, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0xc100))

    @cpu.execute(address: @base_address)
    assert_equal(0x6b, @cpu.read_ram(address: 0xc100))
  end

  # C000 STA $C2
  # C002 BRK
  def test_STA_zero_page
    load_memory %w[85 c2 00]

    @cpu.accumulator = 0x6a
    @cpu.write_ram(address: 0x00c2, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0x00c2))
    @cpu.execute(address: @base_address)
    assert_equal(0x6a, @cpu.read_ram(address: 0x00c2))
  end

  # C000 STA $C2,x
  # C002 BRK
  def test_STA_zero_page_x
    load_memory %w[95 c2 00]

    @cpu.accumulator = 0x69
    @cpu.x_register = 0x10
    @cpu.write_ram(address: 0x00d2, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0x00d2))
    @cpu.execute(address: @base_address)
    assert_equal(0x69, @cpu.read_ram(address: 0x00d2))
  end

  # C000 STX $C201
  # C003 BRK
  def test_STX_absolute
    load_memory %w[8e 01 c2 00]

    @cpu.x_register = 0x7f
    @cpu.write_ram(address: 0xc201, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0xc201))
    @cpu.execute(address: @base_address)
    assert_equal(0x7f, @cpu.read_ram(address: 0xc201))
  end

  # C000 STX $C2
  # C002 BRK
  def test_STX_zero_page
    load_memory %w[86 c2 00]

    @cpu.x_register = 0x7e
    @cpu.write_ram(address: 0x00c2, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0x00c2))
    @cpu.execute(address: @base_address)
    assert_equal(0x7e, @cpu.read_ram(address: 0x00c2))
  end

  # C000 STX $C2,y
  # C002 BRK
  def test_STX_zero_page_y
    load_memory %w[96 c2 00]

    @cpu.x_register = 0x7d
    @cpu.y_register = 0x10
    @cpu.write_ram(address: 0x00d2, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0x00d2))
    @cpu.execute(address: @base_address)
    assert_equal(0x7d, @cpu.read_ram(address: 0x00d2))
  end

  # C000 STY $C201
  # C003 BRK
  def test_STY_absolute
    load_memory %w[8c 01 c2 00]

    @cpu.y_register = 0x7c
    @cpu.write_ram(address: 0xc201, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0xc201))
    @cpu.execute(address: @base_address)
    assert_equal(0x7c, @cpu.read_ram(address: 0xc201))
  end

  # C000 STY $C2
  # C002 BRK
  def test_STY_zero_page
    load_memory %w[8c c2 00]

    @cpu.y_register = 0x7b
    @cpu.write_ram(address: 0x00c2, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0x00c2))
    @cpu.execute(address: @base_address)
    assert_equal(0x7b, @cpu.read_ram(address: 0x00c2))
  end

  # C000 STY $C2,x
  # C002 BRK
  def test_STY_zero_page_x
    load_memory %w[94 c2 00]

    @cpu.x_register = 0x10
    @cpu.y_register = 0x7a
    @cpu.write_ram(address: 0x00d2, data: 0x00)
    assert_equal(0x00, @cpu.read_ram(address: 0x00d2))
    @cpu.execute(address: @base_address)
    assert_equal(0x7a, @cpu.read_ram(address: 0x00d2))
  end

  # C000 TAX
  # C001 BRK
  # C002 TAX
  # C003 BRK
  # C004 TAX
  # C005 BRK
  def test_TAX
    load_memory %w[aa 00 aa 00 aa 00]

    @cpu.accumulator = 0x20
    @cpu.execute(address: @base_address)
    assert_equal(@cpu.x_register, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # Z flag
    @cpu.accumulator = 0x00
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.x_register, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # N flag
    @cpu.accumulator = 0x80
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.x_register, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 TAY
  # C001 BRK
  # C002 TAY
  # C003 BRK
  # C004 TAY
  # C005 BRK
  def test_TAY
    load_memory %w[a8 00 a8 00 a8 00]

    @cpu.accumulator = 0x20
    @cpu.execute(address: @base_address)
    assert_equal(@cpu.y_register, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # Z flag
    @cpu.accumulator = 0x00
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.y_register, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # N flag
    @cpu.accumulator = 0x80
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.y_register, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 TSX
  # C001 BRK
  # C002 TSX
  # C003 BRK
  # C004 TSX
  # C005 BRK
  def test_TSX
    load_memory %w[ba 00 ba 00 ba 00]

    @cpu.stack_pointer = 0x20
    @cpu.execute(address: @base_address)
    assert_equal(@cpu.x_register, @cpu.stack_pointer)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # Z flag
    @cpu.stack_pointer = 0x00
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.x_register, @cpu.stack_pointer)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # N flag
    @cpu.stack_pointer = 0x80
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.x_register, @cpu.stack_pointer)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 TXA
  # C001 BRK
  # C002 TXA
  # C003 BRK
  # C004 TXA
  # C005 BRK
  def test_TXA
    load_memory %w[8a 00 8a 00 8a 00]

    @cpu.x_register = 0x21
    @cpu.execute(address: @base_address)
    assert_equal(@cpu.accumulator, @cpu.x_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # Z flag
    @cpu.x_register = 0x00
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.accumulator, @cpu.x_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # N flag
    @cpu.x_register = 0x80
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.accumulator, @cpu.x_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 TXS
  # C001 BRK
  def test_TXS
    load_memory %w[9a 00]

    @cpu.x_register = 0x22
    @cpu.set_flag(SR_ZERO)
    @cpu.set_flag(SR_NEGATIVE)
    @cpu.execute(address: @base_address)
    assert_equal(@cpu.stack_pointer, @cpu.x_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end

  # C000 TYA
  # C001 BRK
  # C002 TYA
  # C003 BRK
  # C004 TYA
  # C005 BRK
  def test_TYA
    load_memory %w[98 00 98 00 98 00]

    @cpu.y_register = 0x22
    @cpu.execute(address: @base_address)
    assert_equal(@cpu.accumulator, @cpu.y_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # Z flag
    @cpu.y_register = 0x00
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.accumulator, @cpu.y_register)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    # N flag
    @cpu.y_register = 0x80
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(@cpu.accumulator, @cpu.y_register)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))
  end
end
