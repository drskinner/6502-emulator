require './cpu_opcodes.rb'
require './cpu_registers.rb'
require './cpu_status_register.rb'

class Cpu
  include CpuRegisters
  include CpuStatusRegister

  def initialize 
    @accumulator     = 0x00
    @x_register      = 0x00
    @y_register      = 0x00
    @status_register = 0x00
    @stack_pointer   = 0xff
    @program_counter = 0x0000

    # Someday, we'll get on the bus...
    @ram = Array.new(65536).fill(0x00)
  end

  def read_ram(address:)
    return 0x00 if address < 0x0000 || address > 0xffff
    @ram[address]
  end

  def write_ram(address:, data:)
    return if address < 0x0000 || address > 0xffff || data < 0x00 || data > 0xff
    @ram[address] = data
  end

  def execute(address:)
    running = true
    @program_counter = address

    while running
      opcode = @ram[@program_counter]

      instruction = OPCODES[opcode][0]
      address_mode = OPCODES[opcode][1]

      method(instruction).call(address_mode)
      @program_counter += 1

      running = false if opcode.zero?
    end
  end

  #
  # address modes
  #

  # we don't actually need to call for an address in implied mode
  def implied
    puts ' IMPLIED MODE CALLED'
  end

  #
  # Normally, BRK would trigger an interrupt request.
  # We can at least set the B status flag.
  #
  def BRK(mode)
    print "Executing #{@program_counter}: BRK (#{mode})"
    method(mode).call
    set_flag(SR_BREAK)
  end

  def CLC(mode)
    print "Executing #{@program_counter}: CLC (#{mode})"
    method(mode).call
    clear_flag(SR_CARRY)
  end

  def CLD(mode)
    print "Executing #{@program_counter}: CLD (#{mode})"
    method(mode).call
    clear_flag(SR_DECIMAL)
  end

  def CLI(mode)
    print "Executing #{@program_counter}: CLI (#{mode})"
    method(mode).call
    clear_flag(SR_INTERRUPT)
  end

  def NOP(mode)
    print "Executing #{@program_counter}: NOP (#{mode})"
    method(mode).call
  end

  def SEC(mode)
    print "Executing #{@program_counter}: SEC (#{mode})"
    method(mode).call
    set_flag(SR_CARRY)
  end

  def SED(mode)
    print "Executing #{@program_counter}: SED (#{mode})"
    method(mode).call
    set_flag(SR_DECIMAL)
  end

  def SEI(mode)
    print "Executing #{@program_counter}: SED (#{mode})"
    method(mode).call
    set_flag(SR_INTERRUPT)
  end

end
