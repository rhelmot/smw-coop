pushpc
org $0190A2
JSL TurnaroundHijack
pullpc

TurnaroundHijack:
		LDA #$01
		STA $04
		LDA $B6,x
		EOR #$FF
		RTL

PlayerCode:
		STZ $0DB5
		LDA #$03
		STA $0F63
		JSL $04DAAD
		LDA $0DB2
		BEQ .singleplayer

		STZ $0DB2
		LDA #$01
		STA $0DB3
		LDA #$04
		STA $0DB5
	.singleplayer
		RTL

pushpc
org $00F71D
JSL Posaverage

org $00F770
JSL Posaverage
pullpc

Posaverage:
		SBC $1A
		STA $00
		LDX $0DB3
		BEQ .return
		LDA $0100
		AND #$00FF
		CMP #$0014
		BNE .mwins
		LDX $0F65
		LDA $14C8,x
		AND #$00FF
		BEQ .mwins
		LDA $1528,x
		AND #$00FF
		CMP #$0075
		BNE .mwins
		SEP #$20
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		SEC
		SBC $1A
		STA $02
		LDA $0F63
		BIT #$0002
		BEQ .lwins
		BIT #$0008
		BEQ .mwins
		LDA $02
		CMP $00
		BCC .mwins
	.lwins
		LDA $02
		STA $00
		RTL
	.mwins
		LDA $00
	.return
		RTL

pushpc
org $00F801
JSL VPosaverage
pullpc

VPosaverage:
		SBC $1C
		STA $00
		LDX $0DB3
		BEQ .return
		LDA $0100
		AND #$00FF
		CMP #$0014
		BNE .mwins
		LDX $0F65
		LDA $7FAB10,x
		AND #$00FF
		BEQ .mwins
		SEP #$20
		LDA $14D4,x
		XBA
		LDA $D8,x
		REP #$20
		SEC
		SBC $1C
		STA $02
		LDA $0F63
		BIT #$0002
		BEQ .lwins
		BIT #$0008
		BEQ .mwins
		LDA $02
		CMP $00
		BCS .mwins
	.lwins
		LDA $02
		STA $00
		RTL
	.mwins
		LDA $00
	.return
		RTL

pushpc
org $00F606
LDA #$75
STA $00
JSL NewMarioDeath
NOP
pullpc

NewMarioDeath:
		LDA $0F63
		BIT #$03
		BEQ .nosfx
		LDA $00
		CMP #$75
		BNE +
		LDA #$90
		STA $7D
	+
		STZ $140D
		STZ $19
		LDA $0DB3
		BEQ .return
		LDA $0F63
		BIT #$02
		BEQ .nosfx
		LDA $0F63
		BIT #$08
		BEQ .return
		LDA #$03
		TRB $0F63
		LDA #$23
		STA $1DF9
		DEC $0DB4
		LDA #$A0
		STA $0F66
	.nosfx
		PLA
		PLA
		PLA
		RTL
	.return
		DEC $0DB4
		LDA #$09
		STA $1DFB
		RTL

pushpc
org $008E1A
JSL ControllerButtons
NOP
pullpc

ControllerButtons:
		LDA $0DB3
		BEQ .return
		LDA $0F63
		BIT #$02
		BNE .return
		STZ $17
		STZ $77
		BIT #$03
		BNE .notreallydead
		STZ $7B
		STZ $16
		STZ $18
		LDA #$3E
		STA $13E0
		LDA $13
		LSR
		LSR
		AND #$01
		STA $76
		BRA .almostreturn
	.notreallydead
		LDA #$24
		STA $13E0
		LDA $15
		AND #$03
		BEQ .almostreturn
		AND #$01
		STA $76
	.almostreturn
		STZ $15
	.return
		LDA $1493
		ORA $9D
		RTL

pushpc
org $00EADB
LDA $96
JML MarioNoObject
pullpc

MarioNoObject:
		AND #$0F
		STA $90
		LDA $0DB3
		BEQ .return
		LDA $0F63
		BIT #$02
		BNE .return
		JML $80EB21
	.return
		JML $80EAE1

pushpc
org $03B66E
JSL MarioNoSprite
pullpc

MarioNoSprite:
		ADC #$00
		STA $08
		LDA $0DB3
		BEQ .softreturn
		LDA $0F63
		BIT #$02
		BNE .softreturn
		LDA #$F0
		STA $08
	.softreturn
		RTL

pushpc
org $05B16E
JML P2closmbox
pullpc

P2closmbox:
		LDA $0DA5
		AND #$C0
		ORA $0DA3       ; \
		AND #$F0                ;  |If start, select, a, b, x, or y is pressed,
		BEQ .fail           ; / do the below
		STA $00
		LDA $0DA9
		AND #$C0
		ORA $0DA7                   ; \
		EOR $00
		AND #$F0                ;  |If any buttons have been pressed that aren't this frame
		BEQ .succeed           ; / do some of the below
		LDA $0DA5       ;
		AND #$C0                ;
		BEQ .fail           ;
		EOR $0DA9                   ; Same as above, but for controller data 2?
		AND #$C0                ;
		BNE .fail           ;
	.succeed
			JML $85B186
	.fail
		LDA $15
		AND #$F0
		JML $85B172

pushpc
org $01C7C6
JSL BrnPlatpxls
NOP
pullpc

BrnPlatpxls:
		SBC $C2,x
		STA $1491
		STA $1534,x
		RTL

;		##############################################
;		####### From No More Sprite Tile Limits ######
;		##############################################

pushpc
org $0180D2
BRA +
NOP #13
+
JSL PickOAMSlot
pullpc

!foundSlot = PickOAMSlot_foundSlot

macro speedup(offset)
		LDA $02FD+<offset>	; get Y position of previous tile in OAM
		CMP #$F0		; F0 means it's free (Y=F0 means it can't be seen)
		BEQ ?notFound		; \  if this isn't free
		LDA.b #<offset>		;  | (the previous one isn't)
		RTS		; /  this is the index
?notFound:
endmacro

macro bulkSpeedup(arg)
		%speedup(<arg>+12)
		%speedup(<arg>+8)
		%speedup(<arg>+4)
		%speedup(<arg>)
endmacro

PickOAMSlot:
		LDA $0DB3		; \  if one player
		BEQ .default		; /  use the old code
.notLastSpr
		LDA $14C8,x		; \ it's not necessary to get an index
		BEQ .return		; / if this sprite doesn't exist
		LDA $1528,x
		CMP #$75		;  | the first
		BEQ .luigi		; /  two tiles
		JSR SearchAlgorithm	; search for a slot
		BRA .foundSlot

.luigi		LDA #$28		; \ Luigi always gets first 5 tiles (28,2C,30,34,38)
.foundSlot	STA $15EA,x		; / then bubble gets next 5 tiles (3C,40,44,48,4C)
.return		RTL

.default	PHX			; \
		TXA			;  | for when not using
		LDX $1692		;  | custom OAM pointer
		CLC			;  | routine, this is
		ADC $07F0B4,x		;  | the original SMW
		TAX			;  | code.
		LDA $07F000,x		;  |
		PLX			;  |
		STA $15EA,x		; /
		RTL

SearchAlgorithm:
		%bulkSpeedup($F0)	; \
		%bulkSpeedup($E0)	;  | pre-defined
		%bulkSpeedup($D0)	;  | macros with
		%bulkSpeedup($B0)	;  | code for each
		%bulkSpeedup($A0)	;  | individual
		%bulkSpeedup($90)	;  | slot check
		%bulkSpeedup($80)	;  |
		%bulkSpeedup($70)	;  |
		%bulkSpeedup($60)	;  |
		%bulkSpeedup($50)	; /
		LDA #$50		; \ if none of the above yield which slot,
		RTS



pushpc
org $00F597
JML MarioDieProper
pullpc

MarioDieProper:
		LDA $5B
		BIT #$0001
		BNE .vertical
		LDA $96
		CMP #$01C0
		SEP #$20
		BPL .die
	.live
		LDA $1B95
		BNE .byfl
		JML $80F5B6

	.byfl
		JML $80C95B

	.vertical
		LDA $5D
		AND #$00FF
		ASL #8
		CMP $96
		SEP #$20
		BPL .live
	.die
		JML $80F5B2

pushpc
org $00F739
JSR $F8AB
JSL DontJumpScreen
NOP
pullpc

DontJumpScreen:
		LDY $55
		LDA $02
		EOR $F6A3,y
		EOR #$FFFF
		CMP #$0008
		BCC .smallenough
		CMP #$0080
		BCS .toobig
		LDA #$0008
	.toobig
		EOR #$FFFF
		EOR $F6A3,y
		BRA +
	.smallenough
		LDA $02
	+
		CLC
		ADC $1A
		RTL

pushpc
org $00F88B
JSL DontJumpScreenV
NOP #6
pullpc

DontJumpScreenV:
		LDA $02
		BCC .sumpinelse
		EOR $F6A3,y
		EOR #$FFFF
		CMP #$0008
		BCC .smallenough
		CMP #$0080
		BCS .toobig
		LDA #$0008
	.toobig
		EOR #$FFFF
		EOR $F6A3,y
		BRA +
	.smallenough
		LDA $02
	+
		CLC
		ADC $1C
		RTL
	.sumpinelse
		LDA $F6A7,y
		CLC
		ADC $1C
		RTL

pushpc
org $00E9A1
JML MarioNoSide
pullpc

MarioNoSide:
		LDA $0F63
		BIT #$02
		BEQ .skipstuff
		LDA $7E
		CMP #$F0
		JML $80E9A5
	.skipstuff
		JML $80E9FB

pushpc
org $05DA17
JSL SimpleShift
NOP
pullpc

SimpleShift:			;hijack level loading routine and place luigi behind mario.
		SEP #$30
		PHX
		LDX $0F65
		LDA $94
		STA $E4,x
		LDA $95
		STA $14E0,x
		LDA $96
		STA $D8,x
		LDA $97
		STA $14D4,x
		PLX
		LDA $13BF
		RTL

OverSpriteDraw:
		LDX #$00
		LDA $0DB3
		BEQ .end
		STA $0DB2		;set luigi OW information to mario's
		LDA $1F13
		STA $1F15
		LDA $1F11
		STA $1F12
		REP #$30
		LDA $1F19
		STA $1F1D
		LDA $1F17		;except xpos
		CLC
		ADC #$0004
		STA $1F1B		;L = m+4
		SEC
		SBC #$0008
		STA $1F17		;M = l-8 = m-4
	.end
		REP #$30
		LDA $1F17
		SEC
		JML $848637		;jump back to original code

EndFixMarioLong:
		SEP #$30
		LDA $0DB3
		BEQ .end
		REP #$30
		LDA $1F17
		CLC
		ADC #$0004
		STA $1F17
		SEP #$30
		STZ $0DB2
	.end
		RTL

pushpc
org $00D0D8
JML PickDeath
pullpc

PickDeath:
		LDA $0DB4
		BPL .notgameover
		LDA $0DB5
		BPL .notgameover
		JML $80D0DD
	.notgameover
		JML $80D0E6


LuigiOWLives:				; Stripe Image Bullshit -- though it's additional bullshit I didn't comment this the first time through
		LDA $7F837B
		TAX
		REP #$20
		LDA #$6250
		STA $7F837D,x
		INX : INX
		LDA #$0F00
		STA $7F837D,x
		INX : INX
		SEP #$20
		LDA #$00
		JSR GetCharacter
		TAY
		PHB
		PHK
		PLB
	if !THREEPLAYER
		LDA.w NameOffsets,y
		TAY
	-
		LDA.w CharNames,y
		STA $7F837D,x
		INX
		LDA #$38
		STA $7F837D,x
		INX
		INY
		CPY #$05
		BEQ +
		CPY #$0A
		BEQ +
		CPY #$0F
		BNE -
	+
	else
		LDY #$30
	-
		TYA
		STA $7F837D,x
		INX
		LDA #$28
		STA $7F837D,x
		INX
		INY
		CPY #$35
		BNE -
	endif
	+
		PLB
		LDA #$8F
		STA $7F837D,x
		INX
		LDA #$38
		STA $7F837D,x
		INX
		PHX
		LDA $0DB4
		INC
		JSL HexToDecHijack
		TXY
		PLX
		PHA
		CPY #$00
		BNE +
		LDA #$FE
		STA $7F837D,x
		INX
		LDA #$38
		STA $7F837D,x
		INX
		BRA ++
	.nosecondname
		PLB
		RTL

	+
		TYA
		CLC
		ADC #$22
		STA $7F837D,x
		INX
		LDA #$39
		STA $7F837D,x
		INX
	++
		PLA
		CLC
		ADC #$22
		STA $7F837D,x
		INX
		LDA #$39
		STA $7F837D,x
		INX
		LDA #$FF
		STA $7F837D,x
		TXA
		STA $7F837B

		LDA $0DB3
		BEQ .nosecondname

		REP #$20
		LDA #$8250
		STA $7F837D,x
		INX : INX
		LDA #$0F00
		STA $7F837D,x
		INX : INX
		SEP #$20
		LDA #$01
		JSR GetCharacter
		TAY
		PHB
		PHK
		PLB
	if !THREEPLAYER
		LDA.w NameOffsets,y
		TAY
	-
		LDA.w CharNames,y
		STA $7F837D,x
		INX
		LDA #$38
		STA $7F837D,x
		INX
		INY
		CPY #$05
		BEQ +
		CPY #$0A
		BEQ +
		CPY #$0F
		BNE -
	+
	else
		LDY #$40
	-
		TYA
		STA $7F837D,x
		INX
		LDA #$28
		STA $7F837D,x
		INX
		INY
		CPY #$45
		BNE -
	endif
		PLB
		LDA #$8F
		STA $7F837D,x
		INX
		LDA #$38
		STA $7F837D,x
		INX
		PHX
		LDA $0DB5
		INC
		JSL HexToDecHijack
		TXY
		PLX
		PHA
		CPY #$00
		BNE +
		LDA #$FE
		STA $7F837D,x
		INX
		LDA #$38
		STA $7F837D,x
		INX
		BRA ++
	+
		TYA
		CLC
		ADC #$22
		STA $7F837D,x
		INX
		LDA #$39
		STA $7F837D,x
		INX
	++
		PLA
		CLC
		ADC #$22
		STA $7F837D,x
		INX
		LDA #$39
		STA $7F837D,x
		INX
		LDA #$FF
		STA $7F837D,x
		TXA
		STA $7F837B
		PLB
		RTL

if !THREEPLAYER || !!SMALLPLAYERS
pushpc
org $00F5D5
JML BigDeath
pullpc

BigDeath:
		LDA $19
		CMP #$01
		BEQ +
		JML $80F5D9
	+
		JML $80F606
else
pushpc
org $00F5D5
LDA $19
BEQ $2D
pullpc
endif


if !PLAYERKNOCKBACK
pushpc
org $00F5FE
JSL KickBack
LDA #$00
pullpc

KickBack:
		STA $19
		LDA #$D8
		STA $7D
		LDA $76
		BNE +
		LDA #$18
		BRA $02
	+
		LDA #$E8
		STA $7B
		LDA #$60
		STA $1497
		RTL
else
pushpc
org $00F5FE
STA $71
	if !THREEPLAYER || !!SMALLPLAYERS
	STA $19
	else
	STZ $19
	endif
LDA #$2F
pullpc
endif

pushpc
org $00C98B
JML PeaceFix
pullpc

PeaceFix:
		LDA $1493
		CMP #$27
		BCC .dopeace
		JML $80C9A4
	.dopeace
		JML $80C98F

pushpc
org $00CA74
JML CenterOnPlayer
pullpc

CenterOnPlayer:
		LDA $0DB3
		BEQ .marioplus
		LDA $0F63
		PHA
		AND #$0C
		CMP #$0C
		BNE .mario		;if luigi not perfectly alive, do mario
		PLA
		AND #$03
		CMP #$03
		BNE .luigi		;if mario not perfectly alive, do luigi
		LDX $0F65
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		CMP $94
		BCS .luigiplus
		SEP #$20
		PHA
	.mario
		PLA
	.marioplus
		LDA $7E
		CLC
		ADC #$08
		STA $00
		JML $80CA81

	.luigi
		LDX $0F65
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
	.luigiplus
		SEC
		SBC $1A
		SEP #$20
		CLC
		ADC #$08
		STA $00
		LDA $14D4,x
		XBA
		LDA $D8,x
		REP #$20
		SEC
		SBC $1C
		SEP #$20
		SEC
		SBC #$08
		JML $80CA86

pushpc
org $02D4FA
JML BothPlayerProx
pullpc

BothPlayerProx:
		TXY
		LDX $0F65
		LDA $0F63
		BIT #$08
		BEQ .mario
		BIT #$02
		BEQ .luigi
		LDA $94
		SEC
		SBC $00E4,y
		JSR FrcPlus
		STA $0F
		LDA $E4,x
		SEC
		SBC $00E4,y
		JSR FrcPlus
		CMP $0F
		BCC .luigi
	.mario
		TYX
		LDY #$00
		LDA $94
		JML $82D4FE

	.luigi
		LDA $E4,x
		SEC
		SBC $00E4,y
		STA $0F
		LDA $14E0,x
		TYX
		LDY #$00
		JML $82D505

pushpc
org $02FD4A
; LDY $FF50,x
; LDA $1E16,x
JSL BooCielOam
NOP #2
pullpc

BooCielOam:
		JSR SearchAlgorithm
		TAY
		STA $0F
		LDA $1E16,x
		RTL

pushpc
org $008449
JSL DebugOAM
NOP
pullpc

DebugOAM:			; What the hell does this do??
		STZ $4300
		LDA $0DB9
		BIT #$40
		BEQ .end
		LDA $13
		REP #$30
		AND #$007F
		ASL
		ASL
		TAX
		SEP #$20
		STZ $0202,x
		SEP #$10
		BRA .end
		PHA
		AND #$0F
		STA $0386
		PLA
		LSR #4
		STA $0382
		LDA #$60
		STA $0380
		STA $0381
		STA $0385
		LDA #$68
		STA $0384
		LDA #$30
		STA $0383
		STA $0387
	.end
		REP #$20
		RTL

pushpc
org $01CCF0
JSL SaveBrownPlat

pullpc

SaveBrownPlat:
	LDA $151C,x
	STA $1588,x
	LDA $1528,x
	STA $164A,x
	LDA $1504,x
	ASL
	RTL
