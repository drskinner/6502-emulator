module CpuRegisters
  #
  # register read methods
  #
  attr_reader :accumulator
  attr_reader :program_counter
  attr_reader :stack_pointer
  attr_reader :status_register
  attr_reader :x_register
  attr_reader :y_register

  #
  # register write methods; enforce bit widths
  #
  def accumulator=(byte)
    return if byte < 0x00 || byte > 0xff

    @accumulator = byte
  end

  def program_counter=(word)
    return if word < 0x0000 || word > 0xffff

    @program_counter = word
  end

  def stack_pointer=(byte)
    return if byte < 0x00 || byte > 0xff

    @stack_pointer = byte
  end

  def status_register=(byte)
    return if byte < 0x00 || byte > 0xff

    @status_register = byte
  end

  def x_register=(byte)
    return if byte < 0x00 || byte > 0xff

    @x_register = byte
  end

  def y_register=(byte)
    return if byte < 0x00 || byte > 0xff

    @y_register = byte
  end

end