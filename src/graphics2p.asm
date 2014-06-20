HeadDynamsBig:										;which graphical tile corresponds to which pose for the head while big mario
db $38,$38,$38,$50,$38,$38,$38,$38,$38,$38,$50,$3C,$38,$40,$38,$44
db $FF,$FF,$FF,$FF,$FF,$58,$FF,$FF,$FF,$FF,$FF,$FF,$38,$72,$FF,$FF
db $FF,$FF,$FF,$FF,$67,$48,$5B,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
db $A1,$A2,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$65,$38,$8C,$4B
db $65,$65,$FF,$FF,$48,$44,$28

FootDynamsBig:										;which graphical tile corresponds to whichpose for the foot while big mario
db $02,$01,$00,$02,$0C,$0B,$0A,$18,$17,$16,$18,$03,$0D,$04,$19,$07
db $FF,$FF,$FF,$FF,$FF,$1E,$FF,$FF,$FF,$FF,$FF,$FF,$1A,$7A,$FF,$FF
db $FF,$FF,$FF,$FF,$6A,$08,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
db $A9,$A9,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$06,$71,$8D,$53
db $65,$65,$FF,$FF,$08,$07,$39

HeadDynamsSmall:										;which graphical tile corresponds to which pose for the head while small mario
db $28,$28,$28,$81,$28,$28,$28,$28,$28,$28,$81,$93,$28,$95,$28,$6D
db $FF,$FF,$FF,$FF,$FF,$5E,$FF,$FF,$FF,$FF,$FF,$FF,$28,$65,$FF,$FF
db $FF,$FF,$FF,$FF,$94,$5E,$6E,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
db $AC,$AC,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$65,$28,$8C,$FF
db $65,$65,$FF,$FF,$5E,$6D,$38

FootDynamsSmall:										;which graphical tile corresponds to whichpose for the foot while small mario
db $39,$30,$30,$89,$4C,$4E,$4E,$52,$4F,$4F,$88,$9B,$5C,$9D,$57,$75
db $FF,$FF,$FF,$FF,$FF,$66,$FF,$FF,$FF,$FF,$FF,$FF,$56,$69,$FF,$FF
db $FF,$FF,$FF,$FF,$9C,$66,$76,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
db $B4,$A5,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$A6,$71,$8D,$FF
db $65,$65,$FF,$FF,$66,$75,$02

CarryCorrections:								;which pose corresponds to the proper pose for carrying something
db $07,$08,$09,$0A,$07,$08,$09,$07,$08,$09,$0A,$09,$09,$0F,$0E,$0F
db $FF,$FF,$FF,$FF,$FF,$15,$FF,$FF,$FF,$FF,$FF,$FF,$1C,$1D,$1E,$FF
db $FF,$FF,$FF,$FF,$09,$25,$26,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
db $B4,$A5,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$1D,$3D,$3E,$3F
db $40,$41,$FF,$FF,$44,$45,$07

ExtraSet:										;which set of 8x8 tiles corresponds to each pose
db $00,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$02,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00

TopY:	                                        ;y offset for the top 8x8 tile for each pose
db $05,$05,$05,$05,$10,$10,$10,$05,$05,$05,$05,$05,$18,$05,$05,$05
db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
db $05,$05,$05,$05,$05,$05,$05

BotY:											;y offset for the bottom 8x8 tile for each pose
db $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$18,$14,$14,$14
db $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14
db $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14
db $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14
db $14,$14,$14,$14,$14,$14,$14

CapeAddresses:
dw $7400,$7440,$7480,$74C0,$7500,$7540,$7580,$75C0
dw $7800,$7840,$7880,$78C0,$7900,$7940,$7980,$79C0

SUB_GFX:										;GRAPHICS
LDA $1337
		JSR Flashing
		JSR GetDrawInfo
		JSR YBump
		JSR CalcFrame
		JSR DecidePriority
		JSR DrawSixteens
		JSR DrawEights
		JSR TileProps
		LDA $0DB9				; \ 
		AND #$18				;  | If you don't have a cape, don't do cape stuff
		CMP #$10				;  |
		BNE +					;  |
		JSR CapeFrame			;  | Otherwise do cape stuff
		JSR DrawCape			;  |
	+							; /
		LDY #$FF
		LDA #$03				; Do we actually need this? I'm pretty sure we don't actually need this.
		JSL $01B7B3
		RTS

Flashing:
		LDA $1540,x         ; \ 
		BEQ .noflash        ;  |
		TAY                 ;  |
		LDA #$01            ;  |
		CPY #$20            ;  |
		BCC .flash          ;  |
		ASL                 ;  |
		CPY #$40            ;  |
		BCC .flash          ;  | A whole bunch of nonsense for deciding if/how fast to flash sprite
		ASL                 ;  |
		CPY #$60            ;  |
		BCC .flash          ;  |
		ASL                 ;  |
	.flash              ;  |
		AND $13             ;  |
		BEQ .noflash        ;  |
		PLA					;  | Pull Flashing() off the stack
		PLA					;  | return from SUB_GFX
	.noflash	            ;  |
		RTS                 ; /

DecidePriority:
		PHX
		LDX #$22
		LDA $0F6A
		BIT #$10
		BEQ +
		LDX #$12
	+
		STX $0F
		PLX
		RTS

YBump:
		LDA $0DB9
		BIT #$18
		BEQ .small
		INC $01
		BRA .big
	.small
		LDA $1510,x
		CMP #$01
		BEQ .raise
		CMP #$05
		BEQ .raise
		CMP #$08
		BEQ .raise
	.big
		LDA $1510,x
		CMP #$02
		BEQ .raise
		CMP #$06
		BEQ .raise
		CMP #$09
		BNE .noraise
	.raise
		DEC $01
	.noraise
		RTS

DrawSixteens:
		LDA #$A0			; \ set tile size designations
		TSB $0412			; /
		LDA $00				; \ 
		STA $0300,y			;  | X position
		STA $0304,y			; /
		LDA $01				; \ 
		STA $0305,y			;  | Y positions
		SEC					;  |
		SBC #$10			;  |
		STA $0301,y			; /
		LDA #$22			; \ 
		STA $0302,y			;  | Tile numbers
		LDA #$20			;  |
		STA $0306,y			; /
		RTS

DrawEights:
		LDA #$0A			; \ Set tile size designations
		TRB $0413			; /
		LDA $157C,x
		BNE +
		LDA $00
		CLC
		ADC #$10
		BRA ++
	+
		LDA $00
		SEC
		SBC #$08
	++
		STA $0308,y
		STA $030C,y
		LDA.w TopY,x
		CLC
		ADC $01
		SEC
		SBC #$10
		STA $0309,y
		LDA $05
		CMP #$12
		BNE +
		LDA $01
		CLC
		ADC #$0C
		SEC
		SBC #$10
		STA $0309,y
	+
		LDA $01
		PHX
		LDX $05
		LDA.w BotY,x
		PLX
		CLC
		ADC $01
		SEC
		SBC #$10
		STA $030D,y
		LDA #$1A
		STA $030A,y
		INC
		STA $030E,y
		RTS

TileProps:
		LDA $157C,x
		CLC
		ROR #3
		ORA $0F
		STA $0303,y
		STA $0307,y
		STA $030B,y
		STA $030F,y
		INC #2
		STA $0313,y
		RTS

CapeFrame:
		LDA $1594,x
		BNE .countdown
		LDA $1588,x
		AND #$04
		BEQ .air
		LDA $B6,x
		BNE +
		LDA $0DA3
		BIT #$03
		BEQ .drop
	+
		LDA $151C,x
		PHA
		PHY
		JSR RunOCSet
		PLY
		LDA $151C,x
		STA $1594,x
		PLA
		STA $151C,x
		BRA .walking
	.countdown
		DEC
		STA $1594,x
	.return
		RTS
		
	.air
		LDA #$04
		STA $1594,x
		LDA $AA,x
		BMI .airup
		LDA $1534,x
		INC
		CMP #$0B
		BCS .seven
		CMP #$07
		BCS .airk
		DEC $1594,x
		CMP #$05
		BCS .six
		LDA #$05
	.six
		STA $1534,x
		RTS
	
	.seven
		LDA #$07
	.airk
		STA $1534,x
		RTS

	.airup
		LDA $0DB9
		BIT #$01
		BNE .walking
		LDA $0F6A
		BIT #$01
		BEQ .drop
	.walking
		LDA $1534,x
		INC
		CMP #$07
		BCS .three
		CMP #$03
		BCS .airupk
	.three
		LDA #$03
	.airupk
		STA $1534,x
		RTS

	.drop
		LDA #$08
		STA $1594,x
		LDA $1534,x
		BEQ .return
		CMP #$02
		BCC .zero
		LDA #$01
		STA $1534,x
		RTS

	.zero
		STZ $1534,x
		RTS

PlusMinusEight:
db $08,$F8

CapeYOffset:
db $00,$FB,$EE

DrawCape:
		LDA #$20			; \ Set tile size designations
		TSB $0413			; /
		LDA $157C,x
		TAX
		LDA.w PlusMinusEight,x
		CLC
		ADC $00
		STA $0310,y
		LDX $0F65
		LDA $1534,x
		LDX #$00
		CMP #$00
		BEQ .gotten
		INX
		CMP #$07
		BCC .gotten
		INX
	.gotten
		LDA.w CapeYOffset,x
		CLC
		ADC $01
		STA $0311,y
		LDA #$06
		STA $0312,y
		LDX $0F65
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   The one, the only, the GetDrawInfo.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPR_T1:             db $0C,$1C
SPR_T2:             db $01,$02

GetDrawInfo:		STZ $186C,x             ; reset sprite offscreen flag, vertical
                    STZ $15A0,x             ; reset sprite offscreen flag, horizontal
                    LDA $E4,x               ; \ 
                    CMP $1A                 ;  | set horizontal offscreen if necessary
                    LDA $14E0,x             ;  |
                    SBC $1B                 ;  |
                    BEQ ON_SCREEN_X         ;  |
                    INC $15A0,x             ; /

ON_SCREEN_X:        LDA $14E0,x             ; \ 
                    XBA                     ;  |
                    LDA $E4,x               ;  |
                    REP #$20                ;  |
                    SEC                     ;  |
                    SBC $1A                 ;  | mark sprite invalid if far enough off screen
                    CLC                     ;  |
                    ADC #$0040              ;  |
                    CMP #$0180              ;  |
                    SEP #$20                ;  |
                    ROL A                   ;  |
                    AND #$01                ;  |
                    STA $15C4,x             ; /
                    BNE INVALID             ;

                    LDY #$00                ; \ set up loop:
                    LDA $1662,x             ;  |
                    AND #$20                ;  | if not smushed (1662 & 0x20), go through loop twice
                    BEQ ON_SCREEN_LOOP      ;  | else, go through loop once
                    INY                     ; /
ON_SCREEN_LOOP:     LDA $D8,x               ; \ 
                    CLC                     ;  | set vertical offscreen if necessary
                    ADC SPR_T1,y            ;  |
                    PHP                     ;  |
                    CMP $1C                 ;  | (vert screen boundry)
                    ROL $00                 ;  |
                    PLP                     ;  |
                    LDA $14D4,x             ;  |
                    ADC #$00                ;  |
                    LSR $00                 ;  |
                    SBC $1D                 ;  |
                    BEQ ON_SCREEN_Y         ;  |
                    LDA $186C,x             ;  | (vert offscreen)
                    ORA SPR_T2,y            ;  |
                    STA $186C,x             ;  |
ON_SCREEN_Y:        DEY                     ;  |
                    BPL ON_SCREEN_LOOP      ; /

                    LDY $15EA,x             ; get offset to sprite OAM
                    LDA $E4,x               ; \ 
                    SEC                     ;  |
                    SBC $1A                 ;  | $00 = sprite x position relative to screen boarder
                    STA $00                 ; /
                    LDA $D8,x               ; \ 
                    SEC                     ;  |
                    SBC $1C                 ;  | $01 = sprite y position relative to screen boarder
                    STA $01                 ; /
                    RTS                     ; return

INVALID:            PLA
					PLA
                    RTS                     ; /
					

;;;;;;;;;;;;;;;;;;
;;
;;  Various utility functions
;;
;;;;;;;;;;;;;;;;;;;
					
GetPtrToTiles:
		PHP
		SEP #$20
		CMP #$00
		REP #$20
		BEQ .small
		LDA.w #HeadDynamsBig
		STA $00
		LDA.w #FootDynamsBig
		STA $02
		PLP
		RTS
	
	.small
		LDA.w #HeadDynamsSmall
		STA $00
		LDA.w #FootDynamsSmall
		STA $02
		PLP
		RTS

TileToAddr:
		REP #$20	;16bit A
		PHA
		AND #$0007
		ASL #6		;each 16x8 tile is $40 bytes, so multiply low 3 bits by #$40 or 2^6
		STA $06		;store to scratch
		PLA
		AND #$00F8
		ASL #7		;each line of 16x16 tiles is $400 bytes, so multiply top 5 bits by $400/8 or 2^7 (b/c they're already multiplied by 8)
		CLC
		ADC $06		;add frame offset
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Bubble Graphics routine
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAW_BUBBLE:
		LDA $0F63
		AND #$03
		CMP #$01
		BEQ .mariobubble
		LDA $0F63
		AND #$0C
		CMP #$04
		BEQ .luigibubble
		RTS
	.mariobubble
		REP #$20
		LDA $94
		STA $00
		LDA $96
		CLC
		ADC #$0010
		STA $02
		BRA .drawbubble
	.luigibubble
		LDA $E4,x
		STA $00
		LDA $14E0,x
		STA $01
		LDA $D8,x
		STA $02
		LDA $14D4,x
		STA $03
		REP #$20
	.drawbubble
		PHX
		LDA $00
		SEC
		SBC $1A
		STA $04
		LDA $02
		SEC
		SBC $1C
		STA $06
		SEP #$20
		STZ $0F
		STZ $0E
		LDY #$3C
	.loopstart
		STZ $0D
		LDA $14
		ASL
		AND #$10
		ORA $0F
		TAX
		REP #$20
		LDA.w BubbleXOffsets,x
		CLC
		ADC $04
		CMP #$FFF1
		BCC .notfarleft
		INC $0D
		BRA .storexoffset
	.notfarleft
		CMP #$0100
		BCS .nostorexoffset
	.storexoffset
		STA $0300,y
		LDA.w BubbleYOffsets,x
		CLC
		ADC $06
		CMP #$FFF0
		BCS .storey
		CMP #$00E2
		BCC .storey
		LDA #$00F0
	.storey
		SEP #$20
		STA $0301,y
		LDX $0E
		LDA.w BubbleTiles,x
		STA $0302,y
		LDA.w BubbleProps,x
		STA $0303,y
		LDA.w BubbleSizes,x
		ORA $0D
		PHA
		TYA
		LSR
		LSR
		TAX
		PLA
		STA $0460,x
		INY
		INY
		INY
		INY
	.nostorexoffset
		SEP #$20
		INC $0F
		INC $0F
		INC $0E
		LDA $0E
		CMP #$05
		BNE .loopstart
		PLX
		RTS


BubbleXOffsets:
dw $FFF8,$0008,$FFF8,$0008,$FFFD,$0000,$0000,$0000
dw $FFF9,$0007,$FFF9,$0007,$FFFD,$0000,$0000,$0000
BubbleYOffsets:
dw $FFF3,$FFF3,$0002,$0002,$FFFA,$0000,$0000,$0000
dw $FFF3,$FFF3,$0003,$0003,$FFFA,$0000,$0000,$0000
BubbleTiles:
db $4A,$4A,$4A,$4A,$0C
BubbleProps:
db $36,$76,$B6,$F6,$36
BubbleSizes:
db $02,$02,$02,$02,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Frame Calculation Routine
;;  Calls a bunch of subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CalcFrame:
		PHY
		LDA $0F63
		BIT #$0C
		BEQ ++
		LDA $1504,x
		BEQ +
	-
		LDA $1510,x
		STA $05
		BRA .nocalcframe			; If in an animation, let the animators deal with the frame
	+
		LDA $9D
		BNE -
		LDA $1426
		BNE -
	++
		JSR CalcDir
		JSR CalcFrameSub
		STA $05
	.nocalcframe
		JSR CorrectCarry
		JSR EightCalcs
		JSR SixteenCalcs
		PLY
		RTS

CorrectCarry:
		LDA $0DB9
		BPL +
		LDY $05
		LDA.w CarryCorrections,y
		STA $05
	+
		LDA $05
		STA $1510,x
		RTS

EightCalcs:
		LDA $0DB9
		AND #$18
		BNE +
		REP #$20
		LDA #$0000
		BRA ++
	+
		LDY $05
		LDA.w ExtraSet,y
		REP #$20
		AND #$00FF
		ASL #6
	++
		CLC
		ADC.w #ExGraphics
if !SEPERATEGFX && !!THREEPLAYER
		CLC
		ADC #$0400					; skip two rows of 8x8s
endif
		STA $0F42
		SEP #$20
		RTS

SixteenCalcs:
		REP #$20
		LDA $00
		PHA
		SEP #$20
		LDA $0DB9
		AND #$18
		JSR GetPtrToTiles
		LDY $05
		LDA ($00),y
		JSR TileToAddr
		CLC
if !SEPERATEGFX && !!THREEPLAYER
		ADC.w #SeperateP2GFX
else
		ADC #$2000
endif
		STA $0F46
		SEP #$20
		LDA ($02),y
		JSR TileToAddr
		CLC
if !SEPERATEGFX && !!THREEPLAYER
		ADC.w #SeperateP2GFX
else
		ADC #$2000
endif
		STA $0F44
		PLA
		STA $00
		SEP #$20
		RTS

CalcFrameSub:
		LDA $0F63
		BIT #$0C
		BEQ .dead
		BIT #$08
		BEQ .bubble
		LDA $0F6A
		BIT #$04
		BNE .climbthing
		LDA $0DB9
		BIT #$04
		BNE .underwater
	-
		LDA $154C,x
		BNE .kickthing
		LDA $0DB9
		BIT #$22
		BNE .lookupdown
		LDA $1588,x
		BIT #$04
		BEQ .skipturncheck
		LDA $1558,x
		BNE .turnaround
	.skipturncheck
		LDA $1564,x
		BNE .fireball
		LDA $1588,x
		BIT #$04
		BEQ .inair
		LDA $1492
		BNE .peace
		LDA $B6,x
		BNE .moving
	.stationary
		LDA $1588,x
		BIT #$04
		BEQ +
		LDA $0DA3
		BIT #$03
		BNE .moving
	+
		LDA #$00
		RTS
		
	.climbthing
		LDA #$15
		RTS
		
	.underwater
		LDA $1588,x
		BIT #$04
		BNE -
		LDA $15AC,x
		AND #$0F
		CMP #$0C
		BCC .swimframe2
		LDA #$17
		RTS
		
	.swimframe2
		CMP #$04
		BCC .swimframe3
		LDA #$18
		RTS
		
	.swimframe3
		LDA #$19
		RTS
		
	.dead
		LDA #$3E
		RTS
		
	.bubble
		LDA #$24
		RTS
		
	.turnaround
		LDA #$0D
		RTS
		
	.kickthing
		LDA #$0E
		RTS
		
	.lookupdown	;A=$0DB9
		AND #$20
		BEQ .duck
		LDA #$03
		RTS
		
	.duck
		LDA #$3C
		RTS
		
	.inair
		JMP .inairh
		
	.fireball
		LDA $1588,x
		BIT #$04
		BEQ .airfireball
		LDA #$3F
		RTS
		
	.airfireball
		LDA #$16
		RTS
		
	.peace
		STZ $AA,x
		STZ $B6,x
		LDA #$26
		RTS

		.moving
		LDA $151C,x			;\ if there is still time remaining on this frame
		BNE .movesame		;/ reuse last frame
		JSR RunOCSet		;else, figure out how long next frame should be based on speed, store to $151C
		LDA $1510,x			;load previous frame
		BRA +
	--
		LDA #$02			;goto first walk frame
		BRA .sprintshift
	+
		CMP #$03
		BCC +
		SEC
		SBC #$04
	+
		DEC
		CMP #$02			;if not a walk/run frame
		BCS --
	.sprintshift
		TAY
		LDA $163E,x
		CMP #$70
		BCC +
		INY #4
	+
		TYA
	.return
		RTS
		
	.movesame
		LDA $1510,x
		CMP #$06
		BCS --
		RTS

		.inairh
		LDA $0DB9
		BIT #$01
		BNE .spinjump
		LDA $0F6A
		BIT #$01
		BNE .sprintjump
		LDA $AA,x
		BMI .upjump
		LDA #$24
		RTS
		
	.upjump
		LDA #$0B
		RTS

	.sprintjump
		LDA #$0C
		RTS
		
.SJFS
db $00,$00,$0F,$0F,$00,$00,$25,$25

	.DoAStandingRoll
		JMP .stationary
		
	.spinjump
		LDA $14
		AND #$04
		LSR
		LSR
		STA $157C,x
		LDA $14
		AND #$07
		TAY
		LDA .SJFS,y
		BEQ .DoAStandingRoll
		RTS

RunOCSet:
		LDA $B6,x
		JSR FrcPlus
		LDY #$08
		CMP #$08
		BCC .moveknown
		DEY
		CMP #$10
		BCC .moveknown
		DEY
		CMP #$18
		BCC .moveknown
		DEY
		DEY
		CMP #$20
		BCC .moveknown
		DEY
		CMP #$28
		BCC .moveknown
		DEY
		CMP #$30
		BCC .moveknown
		DEY
		CMP #$38
		BCC .moveknown
		DEY
	.moveknown
		TYA
		STA $151C,x
		RTS

CalcDir:
		LDA $1493
		BNE .alwaysright
		LDA $0F6A
		BIT #$04
		BNE .climbing
		LDA $0DB9
		BIT #$22
		BNE .return
		LDA $0F63
		BIT #$0C
		BNE .next
		LDA $13
		LSR
		LSR
		AND #$01
		STA $157C,x
		RTS
		
	.next
		LDA $0DA3
		AND #$03
		BEQ .return
		AND #$01
		STA $157C,x
	.return
		RTS
		
	.alwaysright
		LDA #$01
		STA $157C,x
		RTS
	.climbing
		LDA $0DA3
		BIT #$0F
		BEQ .return
		LDA $151C,x
		BNE .return
		LDA #$08
		STA $151C,x
		LDA $157C,x
		EOR #$01
		STA $157C,x
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Mario's graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

                                ;Mario New Graphics
MarioNewGraphics:
		LDA $19
		JSR GetPtrToTiles
		LDY $13E0
		LDA $0F63
		BIT #$03
		BNE +
		LDA $0100
		CMP #$07
		BEQ +
		LDY #$3E                    ; If mario is dead and we're not on the title screen, use the "dead" frame (probably)
    +

		LDA $19
		BNE +
		REP #$20
		LDA #$0000
		BRA ++
	+
		LDA.w ExtraSet,y
		REP #$20
		AND #$00FF
		ASL #6                       ; 4 bits per pixel, 64 pixels per tile, 8 bits per byte, two tiles per 8x8 set ==> x40 bytes (2^6) per 8x8 set
	++
		CLC
		ADC.w #ExGraphics
		STA $0F3A
		SEP #$20

		LDA ($00),y
		JSR TileToAddr                ;  |
		CLC
		ADC #$2000
		STA $0F3C                     ;  |
		SEP #$20                      ;  |
		LDA ($02),y         		  ;  | Set addresses to DMA tiles from
		JSR TileToAddr                ;  |
		CLC
		ADC #$2000
		STA $0F3E                     ;  |
		SEP #$20                      ; /
		RTS


;;;;;;;;;;;;;;;
;;
;;  Get Pointer to current palette data
;;
;;;;;;;;;;;;;;;

GetPaletteP1:
		SEP #$20
		LDA $71                    ; Check current animation
		CMP #$04
		BEQ FireFlashPalette
		LDA $1490                    ; Check if has star
		BNE StarFlashPalette
		LDA $19
		ASL
		JMP UniversalEnd

    FireFlashPalette:
		LDA $13
		LSR
		LSR
		AND #$03
		BRA UniversalEnd

    StarFlashPalette:
		LDA $14
		AND #$03
		BRA UniversalEnd

GetPaletteP2:
		SEP #$20
		LDY $0F65
		LDA $1504,y                ; Check current animation
		CMP #$08
		BEQ FireFlashPalette
		LDA $1570,y                ; Check if has star
		BNE StarFlashPalette
		LDA $0DB9
		AND #$18
		LSR
		LSR
		ORA #$01

    UniversalEnd:
		ASL
		PHX
		TAX
		REP #$20
		LDA $00E2A2,x            ; Load from list of pointers to different palettes
		PLX
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Overworld OAM routine
;;  very simple :)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

OWOAM:
		LDA #$FF
		STA $0F3A
		STA $0F3B
		RTS