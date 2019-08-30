=begin
(A)SSEMBLE    - Assembles a line of 6502 code.
(C)OMPARE     - Compares two sections of memory and reports differences.
(D)ISASSEMBLE - Disassembles a line of 6502 code.
(F)ILL        - Fills a range of memory with the specified byte.
(G)O          - Starts execution at the specified address.
(H)UNT        - Hunts through memory within a specified range for all occurrances of a set of bytes.
(J)UMP        - Jumps to the subroutine at address.
(L)OAD        - Loads a file from disk.
(M)EMORY      - Displays the hexadecimal values of memory locations.
(R)EGISTERS   - Displays the 6502 registers.
(S)AVE        - Saves to tape or disk.
(T)RANSFER    - Transfers code from one section of memory to another.
(V)ERIFY      - Compares memory with disk.
E(X)IT        - Exits MONITOR
(.)           - Assembles a line of 6502 code (same as Assemble).
(>)           - Modifies memory.
(;)           - Modifies 6502 register displays.
(@)           - Displays disk status, sends disk command, displays directory.
(?)           - Display this help file
=end

require './monitor.rb'

m = Monitor.new
Monitor.instance_methods
m.set_up
m.registers
m.main_loop

exit(0)




