.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm

.thumb
push	{r4-r7, lr}

mov r5, r0			@save to r5 for now

b Event

ldr r1, =#0x0203A4EC 		@attacker
@ldr r2, =#0x0203A56C		@defender
ldr r4, =#0x03004E50		@active char struct 
ldr r4, [ r4 ]

ldr r6, =#0x203A958	@action struct
ldrb r0, [r6, #0x11]		@action struct of active unit


@cmp	r0, #0x2 @attack
@beq	End


CheckIfActiveIsPlayer:
@ldr r6, =#0x203A958	@action struct
ldrb	r2, [r6,#0x0C]	@allegiance byte of the current character taking action
			@0xXY, 0x00 = Player, 0x40 = NPC, 0x80 = Enemy. Uses top 2 bits. 
lsr 	r2, #4		@0xXY must become  0x0X
cmp r2, #0
bne CheckIfDefenderIsPlayer
b PlayerIsActive

CheckIfDefenderIsPlayer:

@if active is NOT player, they might be defender... 
ldr r2, =#0x0203A56C		@defender
ldrb r2, [r2, #0xB]		@deployment/allegiance byte
lsr r2, #4		@0xXY must become  0x0X
cmp r2, #0		@defender is not player, end
beq CheckIfAttackerIsAlsoPlayer
b End

CheckIfAttackerIsAlsoPlayer:
@if no battle, check that the attacker is also 0 or a player

ldr r2, =#0x0203A4EC 		@attacker
ldrb r2, [r2, #0xB]		@deployment/allegiance byte
lsr r2, #4		@0xXY must become  0x0X
cmp r2, #0		@defender is not player, end

bne PlayerIsDefender	@if attacker and defender allegiance are both 0, end
b End

@PlayerIsDefender:
b End			@event effects active unit, so can only happen on player phase


@ldrb r1, [r1, #2]	@word: char pointer
@ldr r2, =#0x03004E50		@active char struct 
@ldrh r2, [r2, #2]		@word: char pointer
@cmp r1, r2
@bne End			@active is not attacker, so end



PlayerIsActive:
Attacker:
ldr r1, =#0x0203A4EC 		@attacker
mov r2, #0x70
ldrb r1, [r1, r2]	@byte: level prior to battle
ldr r2, =#0x03004E50		@active char struct 
ldrb r2, [r2, #8]		@byte: current level of active unit 



@cmp r1, #0		@shows most recent attacker. So will not be 0
@beq End
@cmp r2, #0
@beq End

@cmp r1, r2
@beq End			@if we didn't level up, End



@ 203A4EC (FE8) and one for the defender/target at 203A470 (FE7)/203A56C (FE8)

@check if dead
@ldrb	r2, [r4,#0x0C]
@cmp	r2, #0x00
@beq	End

@mov r6, #0x70
@ldrb	r2, [r4,r6]	@level prior to battle




@ldrb	r0, [r4,#0x08]	@current level //r0, [r4,#0x08]
@cmp 	r0, #20		@r0 = 20 eg. is correct
@bne	End		@no levelup, so no promotion


PlayerIsDefender:
ldr	r0,=#0x800D07C		@event engine thingy

@successful roll, give item/money
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
