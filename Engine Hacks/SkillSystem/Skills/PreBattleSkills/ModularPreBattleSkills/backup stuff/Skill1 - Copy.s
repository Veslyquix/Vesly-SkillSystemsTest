.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ Skill1ID, SkillTester+4
.equ d100Result, 0x802a52c

push {r3-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

ldr r0,=#0x0203F101
ldrb r0,[r0]
cmp r0, #15 @skill1 art ID
bne End

@has ElbowRoom
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @defender data
ldr r1, Skill1ID
.short 0xf800
cmp r0, #0
beq End

@r0, r1, r2 free
@pre-loop set a counter
mov r3, #3			@YY as counter
ldr r2,=Skill1Numbers	@table of what to do

@iteration 1: we do stuff based on #0x01, #0x02, and #0x03 in SkillXNumbers
@iteration 2: we do stuff based on #0x04, #0x05, and #0x06 in SkillXNumbers
@iteration 3: we do stuff based on #0x07, #0x08, and #0x09 in SkillXNumbers
@iteration 4: we do stuff based on #0x0A, #0x0B, and #0x0C in SkillXNumbers
@etc.. 

LoopStart:
@Step 1. Break if we are done looping. 
add r3, r3, #1		@counter +1 (1, 4, 7, A, D, 10, 13, etc.)
			@r2 still has =SkillXNumbers 
ldrb r0,[r2,#3]		@r0 now holds iteration goal
add r0, r0
add r0, r0		@r0 * 3 = when to stop 
cmp r3, r0		@is counter is greater than # of iterations?
bgt End			@if so, break outta the loop



@step 2. Load from character/battle struct 

			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r3]		@r1 is now 3x+1 entry of table 
			@eg. 4, 7, A, D, 10, 13, etc. 
ldrh r0,[r4,r1]		@load r3's value of the battle buffer in r7 into r0
add r3, r3, #1		@counter +1 (5, 8, B, E, 11, 14, etc.)


@step 3. get 3x+2 entry of table and branch 
ldrb r1,[r2,r3]		@add? subtract? multiply? etc.  
add r3, r3, #1		@counter +1 (3, 6, 9, C, F, 12, 15, etc.)
			@3x+3 entry of table 

cmp r1, #1		@branch based on table's entry 
beq Add			@1 = add, 2 = sub, 3 = lsl, etc. 
cmp r1, #2
beq Sub
cmp r1, #3
beq Lsl
mov r3, #0xFF
b End			@invalid option, so end 



Add:
			@r2 still has =SkillXNumbers 
ldr r2,=Skill1Numbers	@table of what to do

ldrb r1,[r2,r3]		@by this number @3rd entry 8 damage
add r0,r1 		@
b CheckCap

@add r0, #7 @round up damage
@lsr r0,#3 @/8; net x1.125

Sub:
			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r3]		@by this number 
sub r0,r1 		@
b CheckCap

Lsl:
			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r3]		@by this number 
lsl r0,r1 		@
b CheckCap


CheckCap:
cmp r0, #0x7f @damage cap of 127
ble NotCap
mov r0, #0x7f

NotCap:
sub r3, r3, #2		@counter -2 (1, 4, 7, A, D, 10, 13, etc.)
			@r2 still has =SkillXNumbers 
ldrb r1,[r2,r3]		@r1 is now the 3x+1 entry of your table
strh r0, [r4, r1] 	@final value stored back in
add r3, r3, #2		@counter +2 (3, 6, 9, C, F, 12, 15, etc.)
b LoopStart


End:
pop {r3-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@WORD ElbowRoomID
