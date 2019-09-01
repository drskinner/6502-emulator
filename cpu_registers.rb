module CpuRegisters
  #
  # register read methods
  #
  def accumulator
    @accumulator
  end

  def program_counter
    @program_counter
  end

  def stack_pointer
    @stack_pointer
  end

  def status_register
    @status_register
  end

  def x_register
    @x_register
  end

  def y_register
    @y_register
  end

  #
  # register write methods
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