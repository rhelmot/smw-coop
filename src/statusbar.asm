pushpc

org $008C81     ;status bar tilemap
db $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC	;That's the four tiles for the top of the item box

db $30,$28,$31,$28,$32,$28,$33,$28,$34,$28		;Mario
db $FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C,$FC,$FC
db $FC,$3C,$3D,$3C,$3E,$3C						;TIME
db $3F,$3C,$FC,$38,$FC,$38
db $2E,$3C,$26,$38,$FC,$38						;Coin symb.
db $FC,$38,$00,$38,$FC,$3C						;|of the
db $40,$28,$41,$28,$42,$28,$43,$28,$44,$28		;/status bar

db $26,$38,$FC,$38,$05,$38,$FC,$38	;\Second
db $FC,$38,$FC,$3C,$FC,$FC,$FC,$28	;|Line
db $FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C	;|of
db $FC,$3C,$FC,$3C,$FC,$38,$FC,$38	;|the
db $FC,$38,$FC,$38,$FC,$38,$FC,$38	;|status
db $FC,$38,$00,$38,$FC,$3C,$26,$38	;|bar
db $FC,$38,$05,$38,$FC,$3C

db $FC,$3C,$FC,$3C,$FC,$3C,$FC,$3C		;bottom 4 tiles of the item box

pullpc

CharNames:					; For 3p mode-- the three characters' names
db $0B,$15,$18,$18,$16
db $1C,$0C,$18,$18,$1D
db $0B,$0E,$15,$15,$0E
NameOffsets:				;Where each player starts in the next table
db $00,$05,$0A

pushpc

org $008E6F
StatusBarDraw:		; ...SMW's time rendering loop is stupid, it's
LDX #$00			; actually way smaller unrolled
LDA $0F31
BNE +				; ...actually most of SMW's status bar routine
LDX #$01			; is stupid with my new setup, whoops I'm gonna
LDA #$FC			; rewrite the whole thing
+
STA $0F20
LDA $0F32
BNE +
CPX #$00
BEQ +
LDA #$FC
+
STA $0F21
LDA $0F33
STA $0F22

;;
;Score
;;

LDA $0F36		; I have no idea what this hunk does
STA $00
STZ $01
REP #$20
LDA $0F34
SEC
SBC #$423F
LDA $00
SBC #$000F
BCC +
SEP #$20
LDA #$0F
STA $0F36,x
LDA #$42
STA $0F35
LDA #$3F
STA $0F34
+
SEP #$20

LDA $0F36
STA $00
STZ $01
LDA $0F35
STA $03
LDA $0F34
STA $02
LDX #$0F
LDY #$00
JSR $9012
LDX #$00
-
LDA $0F24,x
BNE .donescore
LDA #$FC
STA $0F24,x
INX
CPX #$06
BNE -
.donescore

;;
;Coins counting
;;

LDA $13CC
BEQ .nocoins
DEC $13CC
INC $0DBF
LDA $0DBF
CMP #$64
BCC .nocoins
INC $0DB4
INC $0DB5
LDA $0DBF
SEC
SBC #$64
STA $0DBF
.nocoins

;;
;P1 Lives
;;

LDA $0DB4
BMI +
CMP #$62
BCC +
LDA #$62
STA $0DB4
+
LDA $0DB5
BMI +
CMP #$62
BCC +
LDA #$62
STA $0DB5
+
LDA $0DB4
INC
JSR $9045		; HexToDec
TXY
BNE +
LDX #$FC
+
STX $0F16		; \ P1 lives
STA $0F17		; /

;;
;Coins rendering
;;

LDA $0DBF
JSR $9045		; HexToDec
TXY
BNE +
LDX #$FC
+
STA $0F0E		; \ Coins
STX $0F0D		; /

;;
;Yoshi coins
;;

LDX #$00
LDA #$2E
-
CPX $1420
BNE +
LDA #$FC
+
STA $0EFF,x
INX
CPX #$06
BNE -

if !THREEPLAYER
	LDA #$00
	print "Bad things happening at $",pc
	JSL GetCharacterLong
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
endif
LDA $0DB3
BNE .twoPlayerDraw
LDA #$FC		; Clear out:
STA $0F2C		; x
STA $0F2E		; lives
STA $0F2D		; lives
STA $0F10		; L
STA $0F11		; U
STA $0F12		; I
STA $0F13		; G
STA $0F14		; I
RTS
.twoPlayerDraw
if !THREEPLAYER
	LDA #$01
	JSL GetCharacterLong
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
endif
LDA $0DB5
INC
JSL $00974C
TXY
BNE +
LDX #$FC
+
STA $0F2E		; \ P2 lives
STX $0F2D		; /
RTS

print "Status bar ends at ",pc

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


pullpc
