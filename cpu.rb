class Cpu
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

  def register_display
    [].tap { |_|
      _ << '%04X' % @program_counter
      _ << '%02X' % @status_register
      _ << '%02X' % @accumulator
      _ << '%02X' % @x_register
      _ << '%02X' % @y_register
      _ << '%02X' % @stack_pointer
    }.join(' ')
  end

  def read(address:)
    return 0x00 if address < 0x0000 || address > 0xffff
    @ram[address]
  end
end
