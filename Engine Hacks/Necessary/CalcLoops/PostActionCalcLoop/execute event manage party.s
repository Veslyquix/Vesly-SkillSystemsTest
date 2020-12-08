.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm

PUSH {lr}

ldr r0, =0x94BCE58 @14BCF48
mov r1, #0x01
blh 0x0800d07c

MOV r0, #0x17
POP {r1}
bx r1


