require './cpu_status_flags.rb'

module CpuInstructions
  #
  # Normally, BRK would trigger an interrupt request.
  # We can at least set the B status flag.
  #
  def BRK(mode)
    print "Executing #{@program_counter}: BRK (#{mode})"
    method(mode).call
    set_flag(SR_BREAK)
    @running = false
  end

  def CLC(mode)
    print "Executing #{'%04X' % @program_counter}: CLC (#{mode})"
    method(mode).call
    clear_flag(SR_CARRY)
  end

  def CLD(mode)
    print "Executing #{'%04X' % @program_counter}: CLD (#{mode})"
    method(mode).call
    clear_flag(SR_DECIMAL)
  end

  def CLI(mode)
    print "Executing #{'%04X' % @program_counter}: CLI (#{mode})"
    method(mode).call
    clear_flag(SR_INTERRUPT)
  end

  def JAM(mode)
    puts "Undefined OPCODE at #{'%04X' % @program_counter}"
    @running = false
  end

  def LDA(mode)
    print "Executing #{'%04X' % @program_counter}: LDA (#{mode})"
    address = method(mode).call
    puts "Returned lookup at #{'%04X' % address}"
    @accumulator = @ram[address]
  end

  def NOP(mode)
    print "Executing #{'%04X' % @program_counter}: NOP (#{mode})"
    method(mode).call
  end

  def SEC(mode)
    print "Executing #{'%04X' % @program_counter}: SEC (#{mode})"
    method(mode).call
    set_flag(SR_CARRY)
  end

  def SED(mode)
    print "Executing #{'%04X' % @program_counter}: SED (#{mode})"
    method(mode).call
    set_flag(SR_DECIMAL)
  end

  def SEI(mode)
    print "Executing #{'%04X' % @program_counter}: SED (#{mode})"
    method(mode).call
    set_flag(SR_INTERRUPT)
  end
end
