module CpuStatusRegister
  def set_flag(flag)
    @status_register |= flag
  end

  def clear_flag(flag)
    @status_register &= ~flag
  end

  # Ruby is terrible at casting to boolean
  def set?(flag)
    (@status_register & flag == 0) ? false : true
  end
end
