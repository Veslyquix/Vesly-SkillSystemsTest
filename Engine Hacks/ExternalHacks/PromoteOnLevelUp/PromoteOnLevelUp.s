.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm

.thumb
push	{r4-r7, lr}

mov r5, r0
@ldr r0, =#0x0203A4EC 		@03004E50
ldr r0, =#0x03004E50
ldr r4, [ r0 ] @ Keep character struct in r4 for the time being.

@ 203A4EC (FE8) and one for the defender/target at 203A470 (FE7)/203A56C (FE8)


@check if dead
ldrb	r2, [r4,#0x0C]
cmp	r2, #0x00
beq	End

mov r6, #0x70
ldrb	r2, [r4,r6]	@level prior to battle
ldrb	r0, [r5,#0x08]	@current level
cmp 	r0, #20		@r0 = 20 eg. is correct

beq	End		@no levelup, so no promotion

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
