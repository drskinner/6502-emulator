require './cpu_status_flags.rb'

module CpuInstructions
  #
  # Normally, BRK would trigger an interrupt request.
  # We can at least set the B status flag.
  #
  def BRK(mode)
    print "Executing #{@program_counter}: BRK (#{mode})" if @log
    method(mode).call
    set_flag(SR_BREAK)
    @running = false
  end

  def CLC(mode)
    print "Executing #{'%04X' % @program_counter}: CLC (#{mode})" if @log
    method(mode).call
    clear_flag(SR_CARRY)
  end

  def CLD(mode)
    print "Executing #{'%04X' % @program_counter}: CLD (#{mode})" if @log
    method(mode).call
    clear_flag(SR_DECIMAL)
  end

  def CLI(mode)
    print "Executing #{'%04X' % @program_counter}: CLI (#{mode})" if @log
    method(mode).call
    clear_flag(SR_INTERRUPT)
  end

  def JAM(mode)
    puts "Undefined OPCODE at #{'%04X' % @program_counter}"
    @running = false
  end

  #
  # Load Accumulator with a byte value. Has many address modes.
  # Z flag set if AC == 0; N flag set if AC bit 7 is set
  #
  def LDA(mode)
    print "Executing #{'%04X' % @program_counter}: LDA (#{mode})" if @log
    address = method(mode).call
    puts "Returned lookup at #{'%04X' % address}" if @log
    @accumulator = @ram[address]

    @accumulator.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (@accumulator & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end

  def NOP(mode)
    print "Executing #{'%04X' % @program_counter}: NOP (#{mode})" if @log
    method(mode).call
  end

  def SEC(mode)
    print "Executing #{'%04X' % @program_counter}: SEC (#{mode})" if @log
    method(mode).call
    set_flag(SR_CARRY)
  end

  def SED(mode)
    print "Executing #{'%04X' % @program_counter}: SED (#{mode})" if @log
    method(mode).call
    set_flag(SR_DECIMAL)
  end

  def SEI(mode)
    print "Executing #{'%04X' % @program_counter}: SED (#{mode})" if @log
    method(mode).call
    set_flag(SR_INTERRUPT)
  end
end
