.thumb
.global ModularPreBattleSkill
.type ModularPreBattleSkill, %function

.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm
@.equ Skill1ID, SkillTester+4
@.equ Skill2ID, SkillTester+4
.equ d100Result, 0x802a52c

ModularPreBattleSkill:
push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

mov r7, #0x00

SkillChecker:
cmp r7, #0x64
bge End
add r7, #0x01
bl CheckNextSkill
cmp r0, #0x00
beq SkillChecker
b Preloop

@r0, r1, r2 free
@pre-loop set a counter

Preloop: @r7 has which entry to do in it
ldr r1, =ModularPreBattleTable
mov r0, r7	@copy skill id into r0
mov r2, #64 @ 64 bytes per entry

mul r0, r2 @entry of the skill we have eg. r0 = 1 * 64
add r2, r1, r0 @Now we have the pointer to the entry we want.

mov r6, #3			@r6 as counter

@iteration 1: we do stuff based on #0x04, #0x05, and #0x06 in ModularPreBattleTable
@iteration 2: we do stuff based on #0x07, #0x08, and #0x09 in ModularPreBattleTable
@iteration 3: we do stuff based on #0x0A, #0x0B, and #0x0C in ModularPreBattleTable
@etc.. 



@Must be combat art?
ldr r0,=#0x0203F101
ldrb r0,[r0]
ldrb r1,[r2,#2]		@r1 now holds cmb art id
cmp r0, r1 		@exit if not combat art ID
beq LoopStart
ldrb r1,[r2,#2]		@r1 now holds cmb art id
cmp r1, #0
bne SkillChecker




LoopStart:
@Step 1. Break if we are done looping. 
add r6, r6, #1		@counter +1 (4, 7, A, D, 10, 13, etc.)
			@r2 still has our =ModularPreBattleTable row
ldrb r0,[r2,#3]		@r0 now holds iteration goal
add r0, r0
add r0, r0		@r0 * 3 = when to stop 
cmp r6, r0		@is counter is greater than # of iterations?
bgt SkillChecker			@if so, break outta the loop



@step 2. Load from character/battle struct 

			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r6]		@r1 is now 3x+1 entry of table 
			@eg. 4, 7, A, D, 10, 13, etc. 
ldrh r0,[r4,r1]		@load r6's value of the battle buffer in r7 into r0
add r6, r6, #1		@counter +1 (5, 8, B, E, 11, 14, etc.)


@step 3. get 3x+2 entry of table and branch 
ldrb r1,[r2,r6]		@add? subtract? multiply? etc.  
add r6, r6, #1		@counter +1 (6, 9, C, F, 12, 15, etc.)
			@3x+3 entry of table 

cmp r1, #1		@branch based on table's entry 
beq Add			@1 = add, 2 = sub, 3 = lsl, etc. 
cmp r1, #2
beq Sub
cmp r1, #3
beq Lsl
mov r6, #0xFF
b End			@invalid option, so end 



Add:
			@r2 still has =SkillXNumbers 
@ldr r2,=Skill1Numbers	@table of what to do

ldrb r1,[r2,r6]		@by this number @3rd entry 8 damage
add r0,r1 		@
b CheckCap

@add r0, #7 @round up damage
@lsr r0,#3 @/8; net x1.125

Sub:
			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r6]		@by this number 
sub r0,r1 		@
b CheckCap

Lsl:
			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r6]		@by this number 
lsl r0,r1 		@
b CheckCap



@Signed / unsigned
@Byte / short

CheckCap:
cmp r0, #0x7f @damage cap of 127
ble NotCap
mov r0, #0x7f

NotCap:
sub r6, r6, #2		@counter -2 (4, 7, A, D, 10, 13, etc.)
			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r6]		@r1 is now the 3x+1 entry of your table
strh r0, [r4, r1] 	@final value stored back in
add r6, r6, #2		@counter +2 (6, 9, C, F, 12, 15, etc.)
b LoopStart

End:
pop { r4 - r7 }
pop { r3 }
bx r3

@End:
@pop {r4-r7, r15}
@.align
@.ltorg
@SkillTester:
@Poin SkillTester
@WORD ElbowRoomID


CheckNextSkill:
push { lr }
ldr r1, =ModularPreBattleTable
mov r0, r7	@copy skill id into r0
mov r2, #64 @ 64 bytes per entry
mul r0, r2 @entry of the skill we have eg. r0 = 1 * 64
add r2, r1, r0 @Now we have the pointer to the entry we want

ldrb r1, [ r2, #1 ] @r1 now has the skill id to have the effect
cmp r1, #0
beq BreakOut
mov r0, r4
blh SkillTester, r3
pop { r3 }
bx r3

BreakOut:
mov r0, r4
blh SkillTester, r3
mov r7, #0xFF		@there is a better way to do this *shrugs*
pop { r3 }
bx r3
