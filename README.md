# 6502-emulator
Emulating MOS 6502 as a learning exercise.

This "emulator" is actually more of a simulator, written as an excuse to brush up on the 6502 instruction set and a bit of Ruby-without-Rails.

This project does not include a bus, clock, or interrupts, but it can run 6502 machine-language programs that don't depend on those features.

The external monitor program allows you to modify, view, and disassemble sections of the virtual memory. You can also load programs from disk and execute them from within the monitor.

From the command line, `ruby ./mon.rb` will start up the virtual machine and drop you into an external monitor program.
