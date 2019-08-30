class Monitor
  public

  def set_up
    puts
    puts 'Ruby shell 6502 monitor'
    puts
  end

  def registers
    puts '   PC  SR AC XR YR SP'
    puts '; 0000 00 00 00 00 F8'
  end

  def main_loop
    running = true

    while running
      print '> '
      a = gets

      case a[0]
      when 'r'
        registers
      when 'x'
        puts 'BYE.'
        running = false
      else
        puts '?'
      end
    end
  end
end
