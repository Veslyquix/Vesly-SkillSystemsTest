.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ CounterID, SkillTester+4
.equ d100Result, 0x802a52c
@ r0 is attacker, r1 is defender, r2 is current buffer, r3 is battle data
push {r4-r7,lr}
mov r4, r0 @attacker
mov r5, r1 @defender
mov r6, r2 @battle buffer
mov r7, r3 @battle data


ldr     r0,[r2]           @r0 = battle buffer                @ 0802B40A 6800     
lsl     r0,r0,#0xD                @ 0802B40C 0340     
lsr     r0,r0,#0xD        @Without damage data                @ 0802B40E 0B40     
mov r1, #0x82 @devil flag OR miss
tst r0, r1
bne End
@ @if another skill already activated, don't do anything

@only when attacker initiates
ldr r0, =0x203a4ec
cmp r4, r0
bne End

@b WeDamage

ldr r0,=#0x0203F101 	@cmb art checking?
ldrb r0,[r0]
@cmp r0, #15 @dragon fang art ID
@bne End

@cmp r0, r2
@ble End		@if regular attack, pair up, or rescue attack, End


@get our table 
ldr r2, =ModularPreBattleTable
@add r2, r2, #2 		@3rd byte is cmb art id in table

@mov r1, #0
mov r3, #0x0		@terminator

@ldrb r1, [r2]


LoopStart:
mov r1, #0xFF		@70 entries in table
add r3, r3, #1 		@counter

cmp r3, r1		@counter too big so give up
bge End

mov r1, #64
add r2, r2, r1

ldrb r1,[r2]		@r1 now holds cmb art id
cmp r0, r1 		@exit if not combat art ID
bne LoopStart

@r2 is now the pointer to the CmbArtId in the correct row
add r2, r2, #1		@pointer to table entry of hp cost
ldrb r1, [r2]		@actual hp cost 

mov r3, r1
add r3, r3, #2		@add 2 to hp cost
b WeDamage

@make sure damage > 0
mov r0, #4
ldrsh r0, [r7, r0]
cmp r0, #0
ble End



@check for liquid ooze here?

WeDamage:
mov r3, #5

@if we proc, set the hp update flag
ldr     r2,[r6]    
lsl     r1,r2,#0xD                @ 0802B42C 0351     
lsr     r1,r1,#0xD                @ 0802B42E 0B49     
mov     r0, #0x1
lsl     r0, #8           @0x100, hp drain/update
orr     r1, r0

@and unset the crit flag
@ mov r0, #1
@ mvn  r0, r0
@ and     r1,r0            @unset it

ldr     r0,=#0xFFF80000                @ 0802B434 4804     
and     r0,r2                @ 0802B436 4010     
orr     r0,r1                @ 0802B438 4308     
str     r0,[r6]                @ 0802B43A 6018   
@ ldrb r0, CounterID
@ strb r0, [r6,#4]

@grab damage dealt
@ldrh r2, [r7, #4] @final damage

mov r2, r3	@damage taken

@ lsr r2, #1 @optionally halve
neg r2, r2 @r2 contains the damage from counter.
mov r3, r2 @save that



mov r0, #5
ldsb r0, [r6, r0] @current hp change
add r2, r0
neg r2, r2

mov r0, #0x13
ldrsb r0, [r4,r0] @curr hp

cmp r2, r0
blt NoKill
sub r2, r0, #1 @can't actually kill
@ add r3, #1
neg r3, r2

NoKill:
neg r2, r2
strb r2, [r6, #5] @set damage

@Update HP
add r0, r3 @new hp
strb r0, [r4, #0x13]


End:
pop {r4-r7}
pop {r15}

.align
.ltorg
SkillTester:
@POIN SkillTester
@WORD CounterID
