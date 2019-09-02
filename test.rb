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

  # C000 LDA #$40  ; immediate
  # C002 BRK
  # C003 LDA #$00  ; test Z flag
  # C005 BRK
  # C006 LDA #$FF  ; test N flag
  # C008 BRK
  # C009 LDA $80   ; zero-page
  # C00C BRK
  # C00D LDA $C000 ; absolute
  # C010 BRK
  def test_LDA
    load_memory %w[a9 40 00 a9 00 00 a9 ff 00 a5 80 00 ad 03 c0]

    @cpu.execute(address: @base_address)
    assert_equal(0x40, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))
    
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0x00, @cpu.accumulator)
    assert_equal(true, @cpu.set?(SR_ZERO))
    assert_equal(false, @cpu.set?(SR_NEGATIVE))

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xFF, @cpu.accumulator)
    assert_equal(false, @cpu.set?(SR_ZERO))
    assert_equal(true, @cpu.set?(SR_NEGATIVE))

    @cpu.write_ram(address: 0x0080, data: 0xff)
    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xff, @cpu.accumulator)

    @cpu.execute(address: @cpu.program_counter)
    assert_equal(0xa9, @cpu.accumulator)
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
