module CpuAddressModes
  #
  # Each instruction calls an "address mode" function to determine
  # where in RAM to get its operand data.
  #

  # we don't actually need to return an address in implied mode;
  # this method could be empty but this puts is useful for debugging.
  def implied
    puts ' IMPLIED MODE CALLED' if @log
  end

  # in immediate mode, the operand is a one-byte literal value
  # so we can increment the PC (which points at the operand in memory)
  # and return the new PC as an address to be read.
  def immediate
    puts ' IMMEDIATE MODE CALLED' if @log
    @program_counter += 1
  end

  # in zero_page mode, the operand is an address of the form 0x00nn.
  # we can simply return this byte as an address.
  def zero_page
    puts ' ZERO PAGE MODE CALLED' if @log
    @program_counter += 1
    @ram[@program_counter] & 0x00ff # mask to enforce zero-page
  end

  # in absolute mode, the operand is a little-endian 2-byte address.
  def absolute
    puts ' ABSOLUTE MODE CALLED' if @log
    @program_counter += 1
    lo = @ram[@program_counter]
    @program_counter += 1
    hi = @ram[@program_counter]

    hi * 0x0100 + lo
  end
end
