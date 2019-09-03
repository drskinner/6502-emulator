require './cpu_status_flags.rb'

module CpuInstructions
  #
  # Normally, BRK would trigger an interrupt request.
  # We can at least set the B status flag.
  #
  def BRK(address:)
    set_flag(SR_BREAK)
    @running = false
  end

  def CLC(address:)
    clear_flag(SR_CARRY)
  end

  def CLD(address:)
    clear_flag(SR_DECIMAL)
  end

  def CLI(address:)
    clear_flag(SR_INTERRUPT)
  end

  #
  # Subtract 1 from memory with wrap-around.
  # We can simulate this wrapping with (byte + 0x100 - 0x01) & 0xff.
  # Subtracting 0x01 is equivalent to adding 0xff with a subsequent mask.
  #
  def DEC(address:)
    @ram[address] = (@ram[address] + 0xff) & 0xff
    @ram[address].zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (@ram[address] & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end

  def DEX(address:)
    @x_register = (@x_register + 0xff) & 0xff
    @x_register.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (@x_register & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end

  def DEY(address:)
    @y_register = (@y_register + 0xff) & 0xff
    @y_register.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (@y_register & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end

  def INX(address:)
    @x_register = (@x_register + 0x01) & 0xff
    @x_register.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (@x_register & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end

  def INY(address:)
    @y_register = (@y_register + 0x01) & 0xff
    @y_register.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (@y_register & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end

  def JAM(address:)
    puts "Undefined OPCODE at #{'%04X' % @program_counter}"
    @running = false
  end

  #
  # Load Accumulator with a byte value. Has many address modes.
  # Z flag set if AC == 0; N flag set if AC bit 7 is set
  #
  def LDA(address:)
    puts "LDA: Returning lookup at #{'%04X' % address}" if @log
    @accumulator = @ram[address]

    @accumulator.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (@accumulator & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end

  def NOP(address:); end

  def SEC(address:)
    set_flag(SR_CARRY)
  end

  def SED(address:)
    set_flag(SR_DECIMAL)
  end

  def SEI(address:)
    set_flag(SR_INTERRUPT)
  end
end
