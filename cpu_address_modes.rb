module CpuAddressModes
  #
  # Each instruction calls an "address mode" function to determine
  # where in RAM to get its operand data.
  #

  # We don't actually need to return an address in implied mode.
  def implied; end

  # In immediate mode, the operand is a one-byte literal value
  # so we can increment the PC (to point at the operand in memory)
  # and return the new PC as an address to be read.
  def immediate
    @program_counter += 1
  end

  # In zero_page mode, the operand is an address of the form 0x00nn.
  # We can simply return this byte as an address.
  def zero_page
    @program_counter += 1
    @ram[@program_counter] & 0x00ff # mask to enforce zero-page
  end

  # In zero_page_x, the X register is added to the operand to get the
  # target address. Overflows "wrap around" so we apply a zero-page mask.
  def zero_page_x
    @program_counter += 1
    (@ram[@program_counter] + @x_register) & 0x00ff
  end

  # In absolute mode, the operand is a little-endian 2-byte address.
  def absolute
    @program_counter += 1
    lo = @ram[@program_counter]
    @program_counter += 1
    hi = @ram[@program_counter]

    hi * 0x0100 + lo
  end

  # In absolute_x, the X register is added to the 2-byte address to get the
  # target address. Overflow addresses "wrap around" from 0xffff to 0x0000.
  #
  # TODO: when the calculated address is on a different page from the operand
  # address, the instruction will require an extra clock cycle to execute.
  def absolute_x
    @program_counter += 1
    lo = @ram[@program_counter]
    @program_counter += 1
    hi = @ram[@program_counter]

    (hi * 0x0100 + lo + @x_register) & 0xffff
  end
end
