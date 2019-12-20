# 6502-emulator
Emulating MOS 6502 as a learning exercise.

This "emulator" is actually more of a simulator, written as an excuse to brush up on the 6502 instruction set and a bit of Ruby-without-Rails.

This project does not include a bus, clock, or interrupts, but it can run 6502 machine-language programs that don't depend on those features.

The external monitor program allows you to modify, view, and disassemble sections of the virtual memory. You can also load programs from disk and execute them from within the monitor. Anyone who's used typical Commodore MLMs will be reasonably comfortable with the terse command syntax of the monitor.

From the command line, `ruby ./mon.rb` will start up the virtual machine and drop you into an external monitor program.

Implemented montior features:

`D <address>` - disassemble memory starting from address.
`G <address>` - execute machine code starting at address.
`l <filename>` - load program from disk.
`m <start> <end>` - hex dump range of memory addresses.
`r` - dispaly 6502 registers (`PC SR AC XR YR SP`).
`x` - exit
`; <value string>` - set registers; expects arguments in order given by `r` above.
`> <address> <byte values>` - write a series of bytes starting at address.
`?` - help.
