.text
.globl main

main:
    addi x8, x0, 512        # x8 = LED base address
    addi x9, x0, 768        # x9 = switch base address
    addi x7, x0, 1024       # x7 = reset button address (needs decoder support)
    addi sp, x0, 256        # stack pointer inside data memory (0-511)

WAIT_INPUT:
    sw   x0, 0(x8)          # clear LEDs
    lw   x10, 0(x9)         # read switches
    beq  x10, x0, WAIT_INPUT
    jal  x1, COUNTDOWN      # x10 = captured value
    jal  x0, WAIT_INPUT     # j WAIT_INPUT

COUNTDOWN:
    addi sp, sp, -16
    sw   x1, 12(sp)         # save return address
    sw   x18, 8(sp)         # save x18
    addi x18, x10, 0        # x18 = count

COUNT_LOOP:
    sw   x18, 0(x8)         # LEDs = count
    addi x5, x0, 1250       # outer counter (use 125 for a 1 MHz clock)
OUTER:                 
    addi x6, x0, 2000       # inner counter
DELAY:
    lw   x11, 0(x7)         # poll reset button
    bne  x11, x0, RESET_EXIT
    addi x6, x6, -1
    bne  x6, x0, DELAY      # 4 cycles/iter -> 8000 + 3 per outer
    addi x5, x5, -1
    bne  x5, x0, OUTER      # 1250 x 8003 = ~10.0M cycles = ~1 s @ 10 MHz
    addi x18, x18, -1
    bne  x18, x0, COUNT_LOOP

RESET_EXIT:
    sw   x0, 0(x8)          # clear LEDs
    lw   x18, 8(sp)
    lw   x1, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(x1)          # return to WAIT_INPUT
