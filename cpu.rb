require './cpu_registers.rb'
require './cpu_opcodes.rb'

class Cpu
  include CpuRegisters

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
  end

  def NOP(mode)
    print "Executing #{@program_counter}: NOP (#{mode})"
    method(mode).call
  end

end
