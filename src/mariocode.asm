MarioCode:
LDA $1B96
BNE NotFarRightRealEnd
LDA $0F63
BIT #$03
BEQ NotFarRightM
LDA $7E								;DON'T LET MARIO WALK OFF SCREEN, EITHER
CMP #$08
BCS NotFarLeftM
REP #$20
LDA $1A			;layer 1 xpos
CLC
ADC #$0008
STA $94		;...plus 8 to sprite xpos
SEP #$20
BRA NotFarRightM
NotFarLeftM:
CMP #$E9
BCC NotFarRightM
REP #$20
LDA $1A
CLC
ADC #$00E8
STA $94
SEP #$20
NotFarRightM:
BRA NotFarRightRealEnd
NotFarRightLMNOP:
LDA $14E0,x
BPL .maybeokay
.notokay
LDA #$0B
STA $0100
BRA NotFarRightRealEnd
.maybeokay
INC
CMP $5D
BNE NotFarRightRealEnd
LDA $E4,x
CMP #$F8
BCS .notokay
NotFarRightRealEnd:


							;No Small mario
LDA $19
BNE +
INC $19
+

								;MARIO COMES BACK
LDA $0F63
BIT #$02
BNE CantComeBackH
LDA $97
CMP #$F0
BNE +
LDA #$FC
STA $97
+
LDA $0F63
BIT #$03
BNE BubbleMarioCode
LDA $0F66
BEQ Labelname12
LDA $14
AND #$01
BNE CantComeBackH
LDA $9D
BNE CantComeBackH
DEC $0F66
CantComeBackH:
JMP CantComeBack

Labelname12:			;generate mario-in-bubble
LDA $0DB4
BMI CantComeBackH
LDA $0DB3
BEQ CantComeBackH
LDA #$01
TSB $0F63
LDA $1A
CLC
ADC #$80
STA $94
LDA $1B
ADC #$00
STA $95
LDA $1C
SEC
SBC #$20
STA $96
LDA $1D
SBC #$00
STA $97
STZ $7B
LDA #$10
STA $7D
STZ $0F67
JMP CantComeBack

BubbleMarioCode:
LDA #$24
STA $13E0
LDA $0F63
BIT #$0C
BNE .lstillthere
STZ $76
STZ $7B
STZ $7D
JMP CantComeBack
.lstillthere
LDA $14E0,X
XBA
LDA $E4,x
REP #$20
STA $02
LDA $94
SEC
SBC $02
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
LDA $16
ORA $18
AND #$C0
BEQ +
LDA #$0F
STA $1DF9
LDA #$06
STA $01
+
LDA $01
CLC
ADC $00
TAY
LDA.w BSpeedTable,y
BMI ++				;if speed to push is negetive, goto neg. routine
LDA $7B
BMI .fourplusx			;if current speed is negetive, (STP is positive), just set the speed
LDA.w BSpeedTable,y
CMP $7B			
BCC +				;if STP is less than CS, just decrement the CS
STA $7B			;otherwise, just use the STP
BRA +++
.fourplusx
LDA.w BSpeedTable,y
STA $7B
BRA +++
+
DEC $7B
BRA +++
++
LDA $7B
BPL .fourminusx			;if current speed is positive, (STP is negetive), just set the speed
LDA.w BSpeedTable,y	
CMP $7B
BCS +				;if STP is greater than CS, just increment the CS
STA $7B			;otherwise, just use the STP
BRA +++
.fourminusx
LDA.w BSpeedTable,y
STA $7B
BRA +++
+
INC $7B
+++
.endofbubx

LDA $1493
BEQ +
LDA $13
AND #$03
BEQ ++
LDA $0F67
CMP #$D0
BMI ++
DEC $0F67
++
JMP .endofbuby
+

LDA $14D4,X
XBA
LDA $D8,x
REP #$20
STA $02
LDA $96
SEC
SBC $02
CLC
ADC #$0050
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
LDA $16
ORA $18
AND #$C0
BEQ +
LDA #$06
STA $01
+
LDA $01
CLC
ADC $00
TAY
LDA.w BSpeedTable,y	;OH GOD WHY DID I NOT DOCUMENT THIS ROUTINE BETTER... or at least less crypticlly
BMI ++				;if speed to push is negetive, goto neg. routine
LDA $0F67
BMI .fourplusy			;if current speed is negetive, (STP is positive), just set the speed
LDA.w BSpeedTable,y
CMP $0F67			
BCC +				;if STP is less than CS, just decrement the CS
STA $0F67			;otherwise, just use the STP
BRA +++
.fourplusy
LDA.w BSpeedTable,y
STA $0F67
BRA +++
+
DEC $0F67
BRA +++
++
LDA $0F67
BPL .fourminusy			;if current speed is positive, (STP is negetive), just set the speed
LDA.w BSpeedTable,y	
CMP $0F67
BCS +				;if STP is greater than CS, just increment the CS
STA $0F67			;otherwise, just use the STP
BRA +++
.fourminusy
LDA.w BSpeedTable,y
STA $0F67
BRA +++
+
INC $0F67
+++
.endofbuby
LDA $0F67
STA $7D

LDA #$02
TSB $0F63
JSL $03B69F
JSL $03B664
LDA #$02
TRB $0F63
JSL $03B72B
BCC CantComeBack
LDA #$01
STA $1DFA
LDA #$19
STA $1DFC
LDA #$90
STA $7D
LDA #$03
TSB $0F63
LDA #$24
STA $13E0
CantComeBack:

LDA $0F68			;???
BEQ .end
LDA $18E4
BEQ .onown
LDA $18E5
CMP #$01
BNE .end
.give
DEC $0F68
LDA $0DB5
INC
CMP #$64
BCC +
LDA #$63
+
STA $0DB5
BRA .end
.onown
LDA $18E5
BEQ .add
DEC $18E5
BRA .end
.add
LDA #$05
STA $1DFC
LDA $0F68
CMP #$01
BEQ .give
LDA #$23
STA $18E5
BRA .give
.end

								;Mario New Graphics
LDA #$00
JSR GetChar
TAY
LDA.w CharOffsets,y
STA $0F
LDY $13E0
LDA $0F63
BIT #$03
BNE +
LDA $0100
CMP #$07
BEQ +
LDY #$3E
+
LDA.w MarioCorrections,y
STA $0F3A
TAY
LDA.w ExtraSet,y
STA $0F3B
LDA.w HeadDynams,y
CLC
ADC $0F
JSR TileToAddr
STA $0F3C
SEP #$20
LDA.w FootDynams,y
CLC
ADC $0F
JSR TileToAddr
STA $0F3E
SEP #$20
LDA $80
CLC
ADC #$06
STA $0319
LDA $0F3A
CMP #$12
BNE +
LDA $80
CLC
ADC #$0C
STA $0319
+
LDA.w BotY,y
CLC
ADC $80
INC
STA $031D
LDA $0311
CMP $0315
BNE +
CMP #$F0
BNE +
STA $0319
STA $031D
+
LDA #$04
TSB $0323
TSB $030B		;???
RTS