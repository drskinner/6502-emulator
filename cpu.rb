require './cpu_opcodes.rb'
require './cpu_address_modes.rb'
require './cpu_instructions.rb'
require './cpu_registers.rb'
require './cpu_status_register.rb'

class Cpu
  include CpuRegisters
  include CpuStatusRegister
  include CpuAddressModes
  include CpuInstructions

  def initialize 
    @accumulator     = 0x00
    @x_register      = 0x00
    @y_register      = 0x00
    @status_register = 0x00
    @stack_pointer   = 0xff
    @program_counter = 0x0000

    # Someday, we'll get on the bus...
    @ram = Array.new(65536).fill(0x00)

    @running = false
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
    @running = true
    @program_counter = address

    while @running
      opcode = @ram[@program_counter]

      if (OPCODES[opcode])
        instruction = OPCODES[opcode][0]
        address_mode = OPCODES[opcode][1]
      else
        instruction = 'JAM'
        address_mode = 'implied'
      end

      method(instruction).call(address_mode)
      @program_counter += 1
    end
  end
end
