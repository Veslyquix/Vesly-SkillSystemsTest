PUSH {r4,lr}   @//UseCommandEffect - assembling this doesn't seem to work properly
MOV r4 ,r0
ADD r1, #0x3D
LDRB r0, [r1, #0x0]
CMP r0, #0x2
BNE 0x80237A8
LDR r0, [PC, #0x20] @ pointer:080237A0 -> 03004E50 (Pointer to work memory of operation character )
LDR r0, [r0, #0x0] @ pointer:03004E50 (Pointer to work memory of operation character ) r0=Unit r0=Unit
LDR r1, [PC, #0x20] @ pointer:080237A4 -> 0203A958 (ActionData@gActionData._u00 )
LDRB r2, [r1, #0x12] @ pointer:0203A96A (ActionData@gActionData.itemSlotIndex )
LSL r2 ,r2 ,#0x1
MOV r1 ,r0
ADD r1, #0x1E
ADD r1 ,r1, R2
LDRH r1, [r1, #0x0] @r1=Unit r1=Unit
BL 0x08028C0C   @//ItemEffect_ErrorMessage
MOV r1 ,r0
MOV r0 ,r4
BL 0x0804F580   @//Menu_CallTextBox
MOV r0, #0x8
B 0x80237E4
NOP
BL 0x0804E884   @//ClearBG0BG1
LDR r0, [PC, #0x3C] @# pointer:080237EC -> 03004E50 (Pointer to work memory of operation character )
LDR r0, [r0, #0x0] @# pointer:03004E50 (Pointer to work memory of operation character ) r0=Unit r0=Unit
LDR r1, [PC, #0x3C] @# pointer:080237F0 -> 0203A958 (ActionData@gActionData._u00 )
LDRB r2, [r1, #0x12] @# pointer:0203A96A (ActionData@gActionData.itemSlotIndex )
LSL r2 ,r2 ,#0x1
MOV r1 ,r0
ADD r1, #0x1E
ADD r1 ,r1, R2
LDRH r1, [r1, #0x0] @r1=Unit r1=Unit
BL 0x08028E60   @//ItemEffect_Call
LDR r0, [PC, #0x30] @# pointer:080237F4 -> 0202BCF0 (ChapterData@gChapterData.Clock )
ADD r0, #0x41
LDRB r0, [r0, #0x0] @# pointer:0202BD31 (ChapterData@gChapterData.Option2 &01=Music (set=off, not set=on) &02=Sound effects (set=off, not set=on) &04=Window color (set=orange, not set=blue) &08=Window color (set=green, not set=blue, set + 0x08 also set=black) &10=Something about displaying B/W/L on stat screen &40=Autoend turns (set=off, not set=on) &80=Subtitle help (set=off, not set=on))
LSL r0 ,r0 ,#0x1E
@CMP r0, #0x0

@ldr r3, =#0x80237A8 @added
CMP r0, #0x0
BLT 0x80237D4
MOV r0, #0x6A
BL 0x080D01FC   @//m4aSongNumStart r0=music id:SOUND
MOV r0, #0x0
BL 0x08003D38   @//SetFont
BL 0x08003D20   @//Font_ResetAllocation
BL 0x0804EF20   @//EndAllMenus Kills *all* E_Menus void
MOV r0, #0x21
POP {r4}
POP {r1}
BX r1
