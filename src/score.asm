pushpc
;score routine hijacks
org $02ADF2
CPY #$10
BCC $0D						;F4
JML NewLives

org $02AEC1
JSL ScoreDisp1	;show proper tiles

org $02AED3
JSL ScoreDisp2	;show proper properties
NOP
pullpc

;Score sprite extra code
ScoreDisp1:
		JSR FixScoreNum
		RTL

ScoreDisp2:
		PHX
		JSR FixScoreNum
		TXY
		PLX
		CPY #$0E
		RTL

FixScoreNum:
		LDA $16E1,x
		CMP #$10
		BCC .end
		SEC
		SBC #$03
		CMP #$10
		BCC .end
		SEC
		SBC #$03
	.end
		TAX
		RTS

LivesToGive:
db $01,$02,$03
db $01,$02,$03

NewLives:
		TYX							;F6
		LDA.l LivesToGive-$10,x		;F7
		CLC
		ADC $0F68
		STA $0F68					;FB
		CPY #$13					;FE
		BCC .onlyL					;00
		TYA
		SEC
		SBC #$06					;D-F: mario, 10-12: luigi, 13-15: both
		TAY
		JML $82AE03
	.onlyL
		JML $82AE35
