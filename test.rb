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
  # C002 SEC
  # C003 BRK
  def test_CLC_SEC
    load_memory %w[18 00 38 00]

    @cpu.execute(address: @base_address)
    assert_equal(false, @cpu.set?(SR_CARRY))
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(true, @cpu.set?(SR_CARRY))
    assert_equal(0xc004, @cpu.program_counter)
  end

  # C000 CLD
  # C001 BRK
  # C002 SED
  # C003 BRK
  def test_CLD_SED
    load_memory %w[d8 00 f8 00]

    @cpu.execute(address: @base_address)
    assert_equal(false, @cpu.set?(SR_DECIMAL))
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(true, @cpu.set?(SR_DECIMAL))
    assert_equal(0xc004, @cpu.program_counter)
  end

  # C000 CLI
  # C001 BRK
  # C002 SEI
  # C003 BRK
  def test_CLI_SEI
    load_memory %w[58 00 78 00]

    @cpu.execute(address: @base_address)
    assert_equal(false, @cpu.set?(SR_INTERRUPT))
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(true, @cpu.set?(SR_INTERRUPT))
    assert_equal(0xc004, @cpu.program_counter)
  end

  # C000 DEC $80 ; zero page
  # C002 BRK
  # C003 DEC $80
  # C005 BRK
  # C006 DEC $C003
  # C008 BRK
  # C009 DEC $80,X
  # C00C BRK
  # C00D DEC $80,X
  # C00F BRK
  # C010 DEC $C000,X
  # C013 BRK
  def test_DEC
    load_memory %w[c6 80 00 c6 80 00 ce 03 c0 00 d6 80 00 d6 80 00 de 00 c0 00 de ff ff]

    @cpu.write_ram(address: 0x0080, data: 0x01)
    @cpu.execute(address: @base_address)
    assert_equal(0x00, @cpu.read_ram(address: 0x0080))
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.read_ram(address: 0x0080))
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xc5, @cpu.read_ram(address: 0xc003))

    @cpu.x_register = 0x0f
    @cpu.write_ram(address: 0x008f, data: 0xc0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xbf, @cpu.read_ram(address: 0x008f))

    @cpu.x_register = 0xff
    @cpu.write_ram(address: 0x007f, data: 0xd0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xcf, @cpu.read_ram(address: 0x007f))

    @cpu.x_register = 0x03
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xc4, @cpu.read_ram(address: 0xc003))

    @cpu.write_ram(address: 0x0002, data: 0xe0)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xdf, @cpu.read_ram(address: 0x0002))
  end

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

  # C000 LDA #$40    ; immediate
  # C002 BRK
  # C003 LDA #$00    ; test Z flag
  # C005 BRK
  # C006 LDA #$FF    ; test N flag
  # C008 BRK
  # C009 LDA $80     ; zero-page
  # C00B BRK
  # C00C LDA $C000   ; absolute
  # C00F BRK
  # C010 LDA $70,x   ; zero-page,x
  # C012 BRK
  # C013 LDA $c000,x ; absolute,x
  # C016 BRK
  # C017 LDA $c000,y ; absolute,y
  # C01A BRK
  def test_LDA
    bytes =  %w[a9 40 00 a9 00 00 a9 ff 00 a5 80 00 ad 03 c0 00]
    bytes += %w[b5 70 00 bd 00 c0 00 b9 00 c0 00]
    load_memory(bytes)

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

    # $0080 = #$ff
    @cpu.write_ram(address: 0x0080, data: 0xff)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.accumulator)

    # $c000 = #$a9
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xa9, @cpu.accumulator)

    # $0080 = #$ff
    @cpu.x_register = 0x10
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.accumulator)

    # $c010 = #$b5
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xb5, @cpu.accumulator)

    # $c00c = #$ad
    @cpu.y_register = 0x0c
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xad, @cpu.accumulator)
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

end
