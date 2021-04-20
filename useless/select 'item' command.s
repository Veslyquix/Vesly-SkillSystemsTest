PUSH {lr}   @//ItemCommandUsability
LDR r0, [PC, #0x20] @# pointer:080232DC -> 03004E50 (Pointer to work memory of operation character )
LDR r2, [r0, #0x0] @# pointer:03004E50 (Pointer to work memory of operation character ) r0=Unit
LDR r0, [r2, #0xC] @r0=Unit r2=Unit
MOV r1, #0x40
AND r0 ,r1
CMP r0, #0x0
BNE 0x80232E0
LDR r0, [r2, #0x4] @r2=Unit
LDRB r0, [r0, #0x4]
CMP r0, #0x51
BEQ 0x80232E0
LDRH r0, [r2, #0x1E] @r2=Unit
CMP r0, #0x0
BEQ 0x80232E0
MOV r0, #0x1
B 0x80232E2
NOP
@080232DC 4E50 0300   //LDRDATA
MOV r0, #0x3
POP {r1}
BX r1
