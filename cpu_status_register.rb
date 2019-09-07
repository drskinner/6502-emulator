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

  def ZN_flags(result)
    result.zero? ? set_flag(SR_ZERO) : clear_flag(SR_ZERO)
    (result & 0x80).zero? ? clear_flag(SR_NEGATIVE) : set_flag(SR_NEGATIVE)
  end
end
