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

  def initialize(log = false)
    @accumulator     = 0x00
    @x_register      = 0x00
    @y_register      = 0x00
    @status_register = 0x00
    @stack_pointer   = 0xff
    @program_counter = 0x0000

    # Someday, we'll get on the bus...
    @ram = Array.new(65536).fill(0x00)

    @log = log
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

  #
  # Top-down stack. Write a byte on page 0x01 at the location indicated by
  # @stack_pointer, and decrement the pointer. The stack pointer does not
  # care if we overflow; 0x100 will roll over to 0x1ff.
  #
  def stack_push_byte(byte:)
    write_ram(address: 0x0100 + @stack_pointer, data: byte & 0xff)
    @stack_pointer = (@stack_pointer + 0xff) & 0xff
  end

  #
  # Increment the stack pointer, and return the byte at that new location,
  # which will become the next available location on the stack. The stack
  # pointer will happily underflow; 0x1ff will roll over to 0x100.
  #
  def stack_pull_byte
    @stack_pointer = (@stack_pointer + 0x01) & 0xff
    read_ram(address: (0x0100 + @stack_pointer) & 0x01ff)
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

      method(instruction).call(address: method(address_mode).call)
      puts "Executing #{'%04X' % @program_counter}: #{instruction} (#{address_mode})" if @log

      @program_counter += 1
    end
  end
end
