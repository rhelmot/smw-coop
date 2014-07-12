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
if !THREEPLAYER
JSR BerryFixes
endif
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

if !THREEPLAYER
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
endif

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

LoadCoopSprite:
		LDX $0F65
		LDA $14C8,x
		BEQ .plzload
		LDA $9E,x
		CMP #$69
		BEQ .earlyreturn
	.plzload
		JSL $02A9DE				;find good sprite slot
		BPL .screwyou
		LDX #$00				;if there's no good sprite slot, take one anyway, screw them
	.screwyou
		TYX						;stick in X
		LDA #$69				;set sprite number
		STA $9E,x
		JSL $07F7D2				;load sprite tables
		LDA #$08
		STA $14C8,x				;set sprite status: normal
		STZ $151C,x				;zero animation timer
		LDA #$75
		STA $1528,x
		STX $0F65				;save sprite index
		LDA #$01
		STA $157C,x
		LDA $1686,x				; \  FOR THE LOVE OF GOD
		ORA #$20				;  | DO NOT TURN INTO A COIN
		STA $1686,x				;  | WHEN LEVEL PASSED
		LDA $190F,x				;  |
		ORA #$02				;  |
		STA $190F,x				; /
		LDA $0F63
		BIT #$08				;if p2 isn't active
		BNE .p2isactive
		LDA #$80
		STA $14D4,x
		LDA #$0C				;deactivate
		TRB $0F63
		JMP .skipposition
		
	.earlyreturn
		RTS
		
	.p2isactive
		LDA #$0C
		TSB $0F63			;set sprite: alive and well
		LDA $94
		SEC
		SBC #$10
		STA $E4,x
		LDA $95
		SBC #$00
		STA $14E0,x
		LDA $96				;set position behind mario
		CLC
		ADC #$10
		STA $D8,x
		LDA $97
		ADC #$00
		STA $14D4,x
		LDA $192A
		AND #$07
		CMP #$07
		BNE +
		LDA #$04
	+
		STA $00				;setup pipe entry
		LDA $0F63			;if mario shouldn't enter
		BIT #$02
		BNE +
		LDA #$80			;shift away mario
		STA $97
		LDA #$03
		TRB $0F63			;absolutely no mario
		LDA $94
		STA $E4,x
		LDA $95
		STA $14E0,x			;luigi exactly where mario was
		BRA .skipfup		;skip relative positioning
	+
		LDA $00
		CMP #$01
		BEQ ++
		CMP #$04
		BEQ +
		CMP #$03
		BNE .skipfup		;horizontal pipes skip vertical bump
	+
		LDA $94
		STA $E4,x
		LDA $95
		STA $14E0,x			;bump forward eight pixels
		LDA $00
		CMP #$03
		BEQ +
		LDA $D8,x
		SEC
		SBC #$28
		STA $D8,x
		LDA $14D4,x
		SBC #$00
		STA $14D4,x			;down pipe: bump up 28
		BRA .skipfup
	+
		LDA $D8,x
		CLC
		ADC #$28
		STA $D8,x
		LDA $14D4,x
		ADC #$00
		STA $14D4,x			;up pipe: bump down 28
		BRA .skipfup

	++
		LDA $E4,x
		CLC
		ADC #$20
		STA $E4,x			;left pipe: shift right 20
		LDA $14E0,x
		ADC #$00
		STA $14E0,x
	.skipfup
		LDA $00					
		BEQ .skipposition		
		CMP #$05				
		BEQ .skipposition		
		CMP #$06				
		BNE +					
		LDA #$40				; \ 
		STA $B6,x				;  |
		LDA #$01				;  |
		TSB $0F6A				;  |
		LDA #$C0				;  |
		STA $AA,x				;  |
		LDA #$09				;  |
		STA $1504,x				;  |
		LDA #$20				; /  shoot from pipe
		STA $151C,x				
		BRA .skipposition

.pipetimes
db $3C,$3C,$47,$43
db $1C,$1C,$1C,$1B

	+
		STA $1504,x
		DEC
		TAY
		LDA $0F63
		BIT #$02
		BNE +
		INY #4
	+
		LDA.w .pipetimes,y
		STA $151C,x
	.skipposition
		LDA #$08
		STA $7FAB10,x
		RTS