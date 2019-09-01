module CpuStatusRegister
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