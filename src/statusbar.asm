org $008C81     ;status bar tilemap                
db $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC	;That's the four tiles for the top of the item box

db $FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C		;Mario
db $FC,$FC,$FC,$FC,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$FC
db $FC,$3C,$3D,$3C,$3E,$3C				;TIME
db $3F,$3C,$FC,$38,$FC,$38
db $2E,$3C,$26,$38,$FC,$38				;Coin symb.
db $FC,$38,$00,$38,$FC,$3C	;|of the
db $FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C	;/status bar

db $FC,$38,$26,$38,$FC,$38,$05,$38	;\Second
db $FC,$38,$FC,$3C,$FC,$FC,$FC,$28	;|Line
db $FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C	;|of
db $FC,$3C,$FC,$3C,$FC,$38,$FC,$38	;|the
db $FC,$38,$FC,$38,$FC,$38,$FC,$38	;|status
db $FC,$38,$00,$38,$FC,$3C,$26,$38	;|bar
db $FC,$38,$05,$38,$FC,$3C,$FC,$3C	;/but the last two bytes are not
db $FC,$3C,$FC,$3C,$FC,$3C		;bottom 4 tiles of the item box

org $008E72
STA $0F20               ;  | 
LDA $0F32               ;  |shift time five to the left
STA $0F21               ;  | 
LDA $0F33               ;  | 
STA $0F22

org $008F7E
STA $0F0E
STX $0F0D

org $008F3B
LDA $0DB4
BMI $09
CMP #$62
BCC $05
LDA #$62
STA $0DB4
LDA $0DB4

org $008F55
STX $0F17		;\shift lives one to the right
STA $0F18		;/
JMP $8F73		; Kill bonus stars

org $008F86
LDA #$00
JSL GetCharLong
TAX
LDA.l NameOffsets,x
TAX
LDY #$00
-
LDA.l CharNames,x
STA $0EF9,y
INX
INY
CPY #$05
BNE -
LDA $0DB3
BNE TwoPlayerDraw
LDA #$FC
STA $0F2C
STA $0F2E
STA $0F2D
RTS
TwoPlayerDraw:
LDA #$26
STA $0F2C
LDA #$01
JSL GetCharLong
TAX
LDA.l NameOffsets,x
TAX
LDY #$00
-
LDA.l CharNames,x
STA $0F10,y
INX
INY
CPY #$05
BNE -
LDA $0DB5
INC
JSL $00974C
STA $0F2E
STX $0F2D
CPX #$00
BNE NoNeedEnd
LDA #$FC
STA $0F2D
NoNeedEnd:
RTS

org $008ED8
db $0F			;move score back 0B

org $008EE2
db $22

org $008EE9
db $22

org $009E13
JSL PlayerCode

org $009E21
LDX $0DB3

org $0485CF
NOP #4

org $0485E8
LDA #$10
STA $00
LDA #$17

org $048616
CPY #$05

org $04861A

LDA #$10

org $048629
CPY #$0A

org $048607
LDA #$36

org $04A514
					  db $50,$62,$00,$0B,$30,$3C,$31,$3C
					  db $32,$3C,$33,$3C,$34,$3C,$8F,$38
					  db $50,$82,$00,$09,$FC,$3C,$FC,$3C
                      db $FC,$3C,$FC,$3C,$FC,$3C,$FF

org $008F32
JSL CoinLife

org $01C545
NOP
NOP
NOP

org $04862E
JML OverSpriteDraw
EndFixMario:
JSL EndFixMarioLong
RTS

org $048786
JMP EndFixMario

org $04828A
LDY $0DB3

org $05DBCA
db $68

org $05DC30
JML LuigiOWLives

org $05DC01
LDA $0DB4
BRA $07
HexToDecHijack:
JSR $DC3A
RTL