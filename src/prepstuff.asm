EverySingleFrame:           ; Gets run... every single frame
PHK                         ; Hijacks $00:9322, GetGameMode in all.log
PEA.w .mycode-1
PEA $84CE
LDA #$80
PHA
PEA $9328
LDA $0100
JML $8086DF					;Run Game

.mycode
PHB
PHK
PLB
;Check Game mode!
JSR BerryFixes
LDA $0100                   ; Load current game mode
CMP #$02
BNE ++
JSR InitOnce                ; If "Fade to title screen", InitOnce(); and end
BRA .end
++
CMP #$07
BEQ +
CMP #$14
BNE ++
+
-
LDA $1337
JSR RunInLevel              ; If "Title Screen" or "Level", run main code
BRA .end
++
CMP #$0D
BEQ +++
CMP #$0E
BEQ +++
CMP #$0F
BEQ +
CMP #$10
BNE .end
+
LDA $141A
BNE -
LDA $71                     ; "Fade to level" modes will RunInLevel() if entering sublevel
CMP #$0A                    ; or if castle/ghost house entrance
BEQ -
+++
JSR OWOAM                   ; For overworld modes
JSR PrepExist

.end
PLB
REP #$20
PLA
LDY #$80
PHY
PHA
SEP #$20
RTL

BerryFixes:
REP #$20
LDA $0D76
CMP #$6D80
BEQ +
CMP #$6F80
BNE ++
+
CLC
ADC #$0C00
STA $0D76
++
SEP #$20
RTS

InitOnce:
LDA #$0F
STA $0F63
RTS

PrepExist:
LDA #$03
LDY $0DB4
BMI .killmario
TSB $0F63
BRA .tryluigi
.killmario
TRB $0F63
.tryluigi
LDA #$0C
LDY $0DB5
BMI .killluigi
TSB $0F63
BRA .end
.killluigi
TRB $0F63
.end
RTS

RunInLevel:
LDX $0F65
LDA $14C8,x
BEQ ++
LDA $1528,x
CMP #$75
BEQ +
++
JSR LoadCoopSprite
LDX $0F65
+
STX $15E9
JSR MarioCode
JSR MAIN_ROUTINE
RTS
