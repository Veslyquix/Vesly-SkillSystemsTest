.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm

.thumb
push	{r4-r7, lr}


mov r5, r0			@save to r5 for now
@ldr r1, =#0x0203A4EC 		@attacker
@ldr r2, =#0x0203A56C		@defender
ldr r4, =#0x03004E50		@active char struct 
ldr r4, [ r4 ]

@ldr r6, =#0x203A958	@action struct
@ldrb r0, [r6, #0x11]		@action struct of active unit
@cmp	r0, #0x2 @attack
@bne	End


CheckIfActiveIsPlayer:
@ldr r6, =#0x203A958	@action struct
ldrb	r2, [r6,#0x0C]	@allegiance byte of the current character taking action
			@0xXY, 0x00 = Player, 0x40 = NPC, 0x80 = Enemy. Uses top 2 bits. 
lsr 	r2, #4		@0xXY must become  0x0X
cmp r2, #0
bne End
b PlayerIsActive




PlayerIsActive:
ldr r1, =#0x0203A4EC 		@attacker
mov r2, #0x70
ldrb r1, [r1, r2]	@byte: level prior to battle
ldr r2, =#0x03004E50		@active char struct 
@ldr r2, [ r2 ]
ldrb r2, [r2, #8]		@byte: current level of active unit 
@cmp r1, r2
@beq End			@if we didn't level up, End


ldr r4, =#0x03004E50		@active char struct 
@ldr r4, =#0x0203A4EC 		@attacker
@ldr r4, [ r4 ]


ldr r4, =#0x03004E50		@active char struct 
ldrb r2, [r4, #0x4]  		@Class->ClassID  GetClassID
ldr r5, =PromoteLevelList
ldrb r1, [r5, r2]    		@=PromoteLevelList[ClassID]
cmp r1, #0x40
bne End


@CMP r0 ,r1
@BLE Exit


ldrb r0, [ r4, #0x04 ] @ Class ID in r0.
@cmp r0, #1
@bne End

ldr r5, =PromoteLevelList
@ldr r5, [ r5 ]

	@mov r2, #1 @ 1 byte per entry
	@mul r0, r2
	@add r2, r0, r5 @ Now we have the pointer to the entry we want.
	@ldrb r1, [ r2 ]

ldrb r1, [ r5, r0 ]
@cmp r1, #0x00
@beq End

@ldr r0, =#0x03004E50		@active char struct 
@ldr r0, [ r0 ]

ldrb r0, [r4, #8]		@byte: current level of active unit 
@cmp r0, #20
@beq End


@cmp r1, #0x40
@bne End 		@If they are lower than promotion level, end 



@blh  0x0800bc50 	@GetUnitStructFromEventParameter	{U}
			@RAM unit pointer 

@ldrb r0, [r4, #0x19] @RAMUnit->Luck
@ldrb r1, [r5, #0x4]  @Class->ClassID  GetClassID
@ldr r2, LuckTable
@ldrb r1, [r2, r1]    @LuckTable[ClassID]
@CMP r0 ,r1
@BLE Exit


@check if dead
@ldrb	r2, [r4,#0x0C]
@cmp	r2, #0x00
@beq	End






Event:
ldr	r0,=#0x800D07C		@event engine thingy
mov	lr, r0
ldr	r0, =PromotionEvent	@promote active if they leveled up
mov	r1, #0x01		@0x01 = wait for events
.short	0xF800

End:
pop 	{r4-r7}
pop	{r0}
bx	r0
.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD DespoilID
@POIN DespoilEvent
