DEADPROL:
LDA $0F63
BIT #$0C
BNE BubbleLuigiCode
STZ $B6,x
STZ $0DA3
STZ $0DA5			; zero out controller registers as to prevent a/b from affecting gravity
STZ $0DA7		
STZ $0DA9
JSR TickPhysics
LDA $9D			;return if sprites locked
BNE .shortend
STZ $B6,x
LDA $0F66
BEQ WhatsThisLabel
LDA $14
AND #$01
BNE .shortend
DEC $0F66
.shortend
RTS

WhatsThisLabel:
LDA $0DB5
BMI ReturnBye
LDA $0DB3
BEQ ReturnBye
LDA #$04
TSB $0F63
LDA $1A
CLC
ADC #$80
STA $E4,x
LDA $1B
ADC #$00
STA $14E0,x
LDA $1C
SEC
SBC #$20
STA $D8,x
LDA $1D
SBC #$00
STA $14D4,x
STZ $B6,x
LDA #$10
STA $AA,x
ReturnBye:
RTS

BubbleLuigiCode:
LDA $9D
BNE ReturnBye
JSR PushEdges
JSR UpdatePosX
JSR UpdatePosY
;JSL $01801A
;JSL $018022
;JSL $01802A		;update positions by speed

LDA $14E0,X
XBA
LDA $E4,x
REP #$20
SEC
SBC $94
CLC
ADC #$0040
BMI +
CMP #$0080
BCS ++
LSR #5
SEP #$20
INC
BRA +++
+
SEP #$20
LDA #$00
BRA +++
++
SEP #$20
LDA #$05
+++
STA $00
STZ $01
LDA $0DA7
ORA $0DA9
AND #$C0
BEQ +
LDA #$0F
STA $1DF9
LDA #$06
STA $01
BRA ++
+
LDA $14
AND #$1F
BNE ++
JMP TryContact
++
LDA $01
CLC
ADC $00
TAY
LDA.w BSpeedTable,y
BMI ++				;if speed to push is negetive, goto neg. routine
LDA $B6,x
BMI .fourplusx			;if current speed is negetive, (STP is positive), just set the speed
LDA.w BSpeedTable,y
CMP $B6,x			
BCC +				;if STP is less than CS, just decrement the CS
STA $B6,x			;otherwise, just use the STP
BRA +++
.fourplusx
LDA.w BSpeedTable,y
STA $B6,x
BRA +++
+
DEC $B6,x
BRA +++
++
LDA $B6,x
BPL .fourminusx			;if current speed is positive, (STP is negetive), just set the speed
LDA.w BSpeedTable,y	
CMP $B6,x
BCS +				;if STP is greater than CS, just increment the CS
STA $B6,x			;otherwise, just use the STP
BRA +++
.fourminusx
LDA.w BSpeedTable,y
STA $B6,x
BRA +++
+
INC $B6,x
+++
.endofbubx

LDA $1493
BEQ +
LDA $13
AND #$03
BEQ ++
LDA $AA,x
CMP #$D0
BMI ++
DEC
STA $AA,x
++
JMP .endofbuby
+

LDA $14D4,X
XBA
LDA $D8,x
REP #$20
SEC
SBC $96
CLC
ADC #$0030
BMI +
CMP #$0080
BCS ++
LSR #5
SEP #$20
INC
BRA +++
+
SEP #$20
LDA #$00
BRA +++
++
SEP #$20
LDA #$05
+++
STA $00
STZ $01
LDA $0DA7
ORA $0DA9
AND #$C0
BEQ +
LDA #$06
STA $01
+
LDA $01
CLC
ADC $00
TAY
LDA.w BSpeedTable,y
BMI ++				;if speed to push is negetive, goto neg. routine
LDA $AA,x
BMI .fourplusy			;if current speed is negetive, (STP is positive), just set the speed
LDA.w BSpeedTable,y
CMP $AA,x			
BCC +				;if STP is less than CS, just decrement the CS
STA $AA,x			;otherwise, just use the STP
BRA +++
.fourplusy
LDA.w BSpeedTable,y
STA $AA,x
BRA +++
+
DEC $AA,x
BRA +++
++
LDA $AA,x
BPL .fourminusy			;if current speed is positive, (STP is negetive), just set the speed
LDA.w BSpeedTable,y	
CMP $AA,x
BCS +				;if STP is greater than CS, just increment the CS
STA $AA,x			;otherwise, just use the STP
BRA +++
.fourminusy
LDA.w BSpeedTable,y
STA $AA,x
BRA +++
+
INC $AA,x
+++
.endofbuby

TryContact:
JSL $03B69F
JSL $03B664
JSL $03B72B
BCC .end
LDA #$01
STA $1DFA
LDA #$19
STA $1DFC
LDA #$90
STA $AA,x
LDA #$0C
TSB $0F63
LDA #$40
TRB $0DB9
.end
RTS

BSpeedTable:
db $04,$02,$01,$FF,$FE,$FC
db $18,$18,$14,$EC,$E8,$E8