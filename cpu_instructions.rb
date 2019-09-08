require './cpu_status_flags.rb'

module CpuInstructions
  def AND(address:)
    @accumulator = @accumulator & @ram[address]
    ZN_flags(@accumulator)
  end

  #
  # BIT has always seemed a little weird...
  # Only flags are affected; not memory or AC.
  #
  def BIT(address:)
    tmp = @accumulator & @ram[address]
    tmp.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (tmp & SR_NEGATIVE).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
    (tmp & SR_OVERFLOW).zero? ? clear_flag(SR_OVERFLOW) : set_flag(SR_OVERFLOW)
  end

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

  def CLV(address:)
    clear_flag(SR_OVERFLOW)
  end

  #
  # Subtract 1 from memory with wrap-around.
  # We can simulate this wrapping with (byte + 0x100 - 0x01) & 0xff.
  # Subtracting 0x01 is equivalent to adding 0xff with a subsequent mask.
  #
  def DEC(address:)
    @ram[address] = (@ram[address] + 0xff) & 0xff
    ZN_flags(@ram[address])
  end

  def DEX(address:)
    @x_register = (@x_register + 0xff) & 0xff
    ZN_flags(@x_register)
  end

  def DEY(address:)
    @y_register = (@y_register + 0xff) & 0xff
    ZN_flags(@y_register)
  end

  def EOR(address:)
    @accumulator = @accumulator ^ @ram[address]
    ZN_flags(@accumulator)
  end

  #
  # Explicitly defined as 0x02 for testing purposes. All other undefined opcodes
  # will resolve to JAM.
  #
  def HLT(address:)
    @running = false
  end

  #
  # Add 1 from memory with wrap-around.
  # We can simulate this wrapping with (byte + 0x01) & 0xff.
  #
  def INC(address:)
    @ram[address] = (@ram[address] + 0x01) & 0xff
    ZN_flags(@ram[address])
  end

  def INX(address:)
    @x_register = (@x_register + 0x01) & 0xff
    ZN_flags(@x_register)
  end

  def INY(address:)
    @y_register = (@y_register + 0x01) & 0xff
    ZN_flags(@y_register)
  end

  def JAM(address:)
    puts "Undefined OPCODE at #{'%04X' % @program_counter}"
    @running = false
  end

  def JMP(address:)
    @program_counter = address
  end

  #
  # Load Accumulator with a byte value. Has many address modes.
  # Z flag set if AC == 0; N flag set if AC bit 7 is set
  #
  def LDA(address:)
    @accumulator = @ram[address]
    ZN_flags(@accumulator)
  end

  #
  # Load X register with a byte value. Has many address modes.
  # Z flag set if XR == 0; N flag set if XR bit 7 is set
  #
  def LDX(address:)
    @x_register = @ram[address]
    ZN_flags(@x_register)
  end

  #
  # Load Y register with a byte value. Has many address modes.
  # Z flag set if YR == 0; N flag set if YR bit 7 is set
  #
  def LDY(address:)
    @y_register = @ram[address]
    ZN_flags(@y_register)
  end

  def NOP(address:); end

  def ORA(address:)
    @accumulator = @accumulator | @ram[address]
    ZN_flags(@accumulator)
  end

  def PHA(address:)
    stack_push_byte(byte: @accumulator)
  end

  def PHP(address:)
    stack_push_byte(byte: @status_register)
  end

  def PLA(address:)
    @accumulator = stack_pull_byte
    ZN_flags(@accumulator)
  end

  def PLP(address:)
    @status_register = stack_pull_byte
  end

  def SEC(address:)
    set_flag(SR_CARRY)
  end

  def SED(address:)
    set_flag(SR_DECIMAL)
  end

  def SEI(address:)
    set_flag(SR_INTERRUPT)
  end

  def STA(address:)
    @ram[address] = @accumulator
  end

  def STX(address:)
    @ram[address] = @x_register
  end

  def STY(address:)
    @ram[address] = @y_register
  end

  def TAX(address:)
    @x_register = @accumulator
    ZN_flags(@x_register)
  end

  def TAY(address:)
    @y_register = @accumulator
    ZN_flags(@y_register)
  end

  def TSX(address:)
    @x_register = @stack_pointer
    ZN_flags(@x_register)
  end

  def TXA(address:)
    @accumulator = @x_register
    ZN_flags(@accumulator)
  end

  # does not affect status flags
  def TXS(address:)
    @stack_pointer = @x_register
  end

  def TYA(address:)
    @accumulator = @y_register
    ZN_flags(@accumulator)
  end
end
