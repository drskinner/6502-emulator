require './cpu.rb'

class Assembler
  def initialize
    @cpu = Cpu.new(true)
    @memory_pager = 0x0000

    puts
    puts 'Ruby shell 6502 monitor'
    puts
  end

  def byte(value)
    '%02X' % value
  end

  def word(value)
    '%04X' % value
  end

  def ascii_to_char(value)
    (value >= 32 && value <= 127) ? value.chr : '.'
  end

  def disassemble(command)
    parts = command.split(' ')

    line_count = 0
    @memory_pager = parts[1].to_i(16) unless parts[1].nil?

    while (line_count <= 0x10)
      instruction = OPCODES[@cpu.read_ram(address: @memory_pager)]
      instruction = %w[??? implied 1 0] if instruction.nil?
      operand1 = @cpu.read_ram(address: @memory_pager + 1)
      operand2 = @cpu.read_ram(address: @memory_pager + 2)

      print "> #{word(@memory_pager & 0xffff)} "
      print "#{instruction[0]}"
      case instruction[1]
      when 'a_implied'
        puts ' A'
      when 'absolute'
        puts " $#{byte operand2}#{byte operand1}"
      when 'absolute_x'
        puts " $#{byte operand2}#{byte operand1},X"
      when 'absolute_y'
        puts " $#{byte operand2}#{byte operand1},Y"
      when 'immediate'
        puts " #$#{byte operand1}"
      when 'implied'
        puts
      when 'indirect'
        puts " ($#{byte operand2}#{byte operand1})"
      when 'indirect_x'
        puts " ($#{byte operand1},X)"
      when 'indirect_y'
        puts " ($#{byte operand1}),Y"
      when 'zero_page'
        puts " $#{byte operand1}"
      when 'zero_page_x'
        puts " $#{byte operand1},X"
      when 'zero_page_y'
        puts " $#{byte operand1},Y"
      end
      @memory_pager += instruction[2].to_i

      line_count += 1
    end
  end

  def go(command)
    parts = command.split(' ')
    return if parts[1].nil?

    @cpu.execute(address: parts[1].to_i(16) & 0xffff)
    registers
  end

  def load(command)
    parts = command.split(' ')
    return if parts[1].nil?

    File.open("./disk/#{parts[1]}", 'r') do |file|
      file.each do |line|
        puts line
        write_memory(line) if line[0] == '>'
      end
    end

  end

  def memory(command)
    parts = command.split(' ')

    @memory_pager = parts[1].to_i(16) unless parts[1].nil?
    top = parts[2].nil? ? @memory_pager + 0x7f : parts[2].to_i(16)

    while (@memory_pager <= top)
      print "> #{word(@memory_pager & 0xffff)} "
      (0..7).each do |offset|
        print "#{byte @cpu.read_ram(address: (@memory_pager + offset) & 0xffff)} "
      end
      (0..7).each do |offset|
        print ascii_to_char(@cpu.read_ram(address: (@memory_pager + offset) & 0xffff))
      end
      
      puts
      @memory_pager += 0x08
    end

    @memory_pager &= 0xffff
  end

  def registers
    puts '   PC  SR AC XR YR SP'
    print '; '
    puts [].tap { |_|
           _ << word(@cpu.program_counter)
           _ << byte(@cpu.status_register)
           _ << byte(@cpu.accumulator)
           _ << byte(@cpu.x_register)
           _ << byte(@cpu.y_register)
           _ << byte(@cpu.stack_pointer)
         }.join(' ')
  end

  def set_registers(command)
    parts = command.split(' ')
    if (parts.count != 7)
      puts '?'
      return
    end

    @cpu.program_counter=(parts[1].to_i(16))
    @cpu.status_register=(parts[2].to_i(16))
    @cpu.accumulator=(parts[3].to_i(16))
    @cpu.x_register=(parts[4].to_i(16))
    @cpu.y_register=(parts[5].to_i(16))
    @cpu.stack_pointer=(parts[6].to_i(16))
    puts
    registers
  end

  def write_memory(command)
    parts = command.split(' ')
    return if parts.count < 3

    start_address = parts[1].to_i(16)
    if (start_address < 0x000 || start_address > 0xffff)
      puts '?'
      return
    end

    parts.shift(2)
    parts.each_with_index do |value, index|
      @cpu.write_ram(address: (start_address + index) & 0xffff, data: value.to_i(16))
    end
  end

  def main_loop
    running = true

    while running
      command = gets.chomp

      case command[0]
      when 'd'
        disassemble(command)
      when 'g'
        go(command)
      when 'l'
        load(command)
      when 'm'
        memory(command)
      when 'r'
        registers
      when 'x'
        puts 'BYE.'
        running = false
      when ';'
        set_registers(command)
      when '>'
        write_memory(command)
      else
        puts '?'
      end
    end
  end
end
