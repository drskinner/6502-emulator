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

  # In zero_page_y, the Y register is added to the operand to get the
  # target address. Overflows "wrap around" so we apply a zero-page mask.
  def zero_page_y
    @program_counter += 1
    (@ram[@program_counter] + @y_register) & 0x00ff
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

  # In absolute_y, the Y register is added to the 2-byte address to get the
  # target address. Overflow addresses "wrap around" from 0xffff to 0x0000.
  #
  # TODO: when the calculated address is on a different page from the operand
  # address, the instruction will require an extra clock cycle to execute.
  def absolute_y
    @program_counter += 1
    lo = @ram[@program_counter]
    @program_counter += 1
    hi = @ram[@program_counter]

    (hi * 0x0100 + lo + @y_register) & 0xffff
  end

  # Indirect mode is only used with the JMP instruction. The operand contains a
  # 16-bit address which identifies the location of the low byte of another
  # 16-bit memory address which is the effective target of the jump.
  #
  # NOTE: the real 6502 has a famous bug: if the low byte of the pointer is 0xff,
  # the the high byte's location is 0x00 and not 0x100 as one would expect. For
  # example, JMP($C0FF) will get its high byte from $C000 instead of $C100.
  def indirect
   @program_counter += 1
   pointer_lo = @ram[@program_counter]
   @program_counter += 1
   pointer_hi = @ram[@program_counter]

   effective_lo = (pointer_hi * 0x0100 + pointer_lo) & 0xffff
   effective_hi = (pointer_hi * 0x0100 + ((pointer_lo + 1) & 0xff)) & 0xffff

   (@ram[effective_hi] * 0x0100 + @ram[effective_lo]) & 0xffff
  end

  # indirect_y is more correctly called "Indirect, Indexed".
  # Indirect, Indexed mode has, as its operand, a zero-page address that
  # holds the low byte of a little-endian two-byte address. To this
  # two-byte address, we add the value of the Y register to determine
  # the final "effective" address.
  #
  # TODO: As with other indexed modes, a change in page costs an additional
  # clock cycle.
  def indirect_y
    @program_counter += 1
    zero_page_address = @ram[@program_counter]
    lo = @ram[zero_page_address]
    hi = @ram[zero_page_address + 1]

    (hi * 0x0100 + lo + @y_register) & 0xffff
  end

  # indirect_x is more correctly called "Indexed, Indirect". In this mode,
  # the 8-bit operand is added to the X register. The result is the low byte
  # of a little-endian two-byte effective address. Zero-page addresses "wrap",
  # so there will be no clock-cycle penalty for crossing a page boundary.
  #
  # "You may never need to use this mode. Indeed, most programmers lead
  #  full, rich lives without ever writing code that uses indexed, indirect
  #  addressing." -- Jim Butterfield
  def indirect_x
    @program_counter += 1
    zero_page_address = (@ram[@program_counter] + @x_register) & 0xff
    lo = @ram[zero_page_address] & 0xff
    hi = @ram[zero_page_address + 1] & 0xff

    (hi * 0x0100 + lo + @y_register) & 0xffff
  end
end
