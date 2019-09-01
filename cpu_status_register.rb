module CpuStatusRegister
  SR_CARRY     = 0x01
  SR_ZERO      = 0x02
  SR_INTERRUPT = 0x04
  SR_DECIMAL   = 0x08
  SR_BREAK     = 0x10
  SR_UNUSED    = 0x20
  SR_OVERFLOW  = 0x40
  SR_NEGATIVE  = 0x80

  def set_flag(flag)
    @status_register |= flag
  end

  def clear_flag(flag)
    @status_register &= ~flag
  end

  def set?(flag)
    @status_register & flag
  end
end