HeadDynams:										;which graphical tile corresponds to which pose for the head
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$0B,$0C,$0D,$25,$01,$0E,$0F
db $20,$10,$12,$00,$11,$1E,$00,$01
db $22,$22,$22,$22,$22,$22,$22

FootDynams:										;which graphical tile corresponds to whichpose for the foot
db $09,$03,$02,$07,$0A,$08,$04,$06
db $05,$13,$14,$15,$1B,$09,$16,$17
db $21,$18,$1A,$1C,$19,$1F,$1D,$04
db $23,$24,$26,$27,$28,$29,$2A

CarryCorrections:								;which pose corresponds to the proper pose for carrying something
db $06,$07,$08,$06,$07,$08,$06,$07
db $08,$07,$0A,$0B,$17,$12,$0A,$0F
db $10,$11,$12,$13,$07,$15,$16,$17
db $18,$07,$1D,$1E,$18,$1D,$1E

MarioCorrections:								;which cmc pose each mario ($13E0) pose corresponds to
db $00,$02,$01,$0D,$03,$04,$05,$06,$08,$07,$17,$09,$19,$0E,$13,$0A
db $FF,$FF,$FF,$FF,$FF,$10,$1C,$18,$1A,$1D,$1B,$1E,$16,$12,$FF,$FF
db $FF,$FF,$FF,$FF,$14,$0B,$11,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$0C,$FF,$15,$0F
db $FF,$FF,$FF,$FF,$0B,$0A,$00

ExtraSet:										;which set of 8x8 tiles corresponds to each pose
db $00,$00,$00,$04,$04,$04,$00,$00
db $00,$00,$01,$01,$05,$02,$00,$00
db $01,$01,$00,$06,$07,$0F,$03,$02
db $08,$08,$0A,$0B,$08,$0C,$09

TopY:	                                        ;y offset for the top 8x8 tile for each pose
db $05,$05,$05,$05,$05,$05,$05,$05
db $05,$05,$05,$05,$05,$05,$05,$05
db $05,$05,$0C,$05,$05,$05,$05,$05
db $05,$05,$05,$05,$05,$05,$05
BotY:											;y offset fot the bottom 8x8 tile for each pose
db $14,$13,$13,$0F,$0F,$0F,$13,$14
db $13,$15,$17,$17,$17,$14,$13,$13
db $16,$16,$16,$15,$0D,$05,$0E,$13
db $16,$16,$13,$16,$15,$16,$17

CharOffsets:				;Starting tiles for players pre-dma
db $00,$30,$60

CapeAddresses:
dw $5400,$5440,$5480,$54C0,$5500,$5540,$5580,$55C0
dw $5800,$5840,$5880,$58C0,$5900,$5940,$5980,$59C0

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
    ADC #$2000	;use the graphics for regular mario, decompressed at $7E2000
    CLC
    ADC $06		;add frame offset
    RTS


                                ;Mario New Graphics
MarioNewGraphics:
    LDA #$00
    JSR GetCharacter
    PHA
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
    LDY #$3E                    ; If mario is dead and we're not on the title screen, use the "dead" frame (probably)
    +
    LDA.w MarioCorrections,y
    TAY

    LDA.w ExtraSet,y
    STA $0F3A
    PLA                          ; Get current character
    ASL #4                       ; Multiply by 10
    CLC
    ADC $0F3A                    ; Add to current 8x8 set -- get current 8x8 set independent of character
    REP #$20
    AND #$00FF
    ASL #6                       ; 4 bits per pixel, 64 pixels per tile, 8 bits per byte, two tiles per 8x8 set ==> x40 bytes (2^6) per 8x8 set
    CLC
    ADC.w #ExGraphics
    STA $0F3A
    SEP #$20

    LDA.w HeadDynams,y            ; \
    CLC                           ;  |
    ADC $0F                       ;  |
    JSR TileToAddr                ;  |
    STA $0F3C                     ;  |
    SEP #$20                      ;  |
    LDA.w FootDynams,y            ;  | Set addresses to DMA tiles from
    CLC                           ;  |
    ADC $0F                       ;  |
    JSR TileToAddr                ;  |
    STA $0F3E                     ;  |
    SEP #$20                      ; /

    LDA.w TopY,y                ; \
    CLC                         ;  |
    ADC $80                     ;  |
    INC                         ;  |
    STA $0319                   ;  | Set Y positions for 8x8 tiles in OAM
    LDA.w BotY,y                ;  |
    CLC                         ;  |
    ADC $80                     ;  |
    INC                         ;  |
    STA $031D                   ; /

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

SUB_GFX:										;GRAPHICS

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
RTS                 ;  |
.noflash            ; /

LDA $0F63
BIT #$0C
BEQ ++
LDA $1504,x
BEQ +
-
LDA $1510,x
STA $05
BRA .nocalcframe
+
LDA $9D
BNE -
LDA $1426
BNE -
++
JSR CalcDir
JSR CalcFrame		;Current Frame should be stored in $05
.nocalcframe
LDA $05
STA $1510,x
LDA $0DB9
BPL ++
LDY $05
LDA.w CarryCorrections,y
STA $05
++
LDY $05
LDA.w ExtraSet,y
STA $0F42
LDA #$01
JSR GetCharacter
ASL #4
CLC
ADC $0F42
REP #$20
AND #$00FF
ASL #6
CLC
ADC.w #ExGraphics
STA $0F42
SEP #$20


;LDY $05
LDA FootDynams,y
LDY #$00
JSR GETSLOT
LDY $05
LDA HeadDynams,y
LDY #$01
JSR GETSLOT
JSR GET_DRAW_INFO

LDX #$22
LDA $0F6A
BIT #$10
BEQ +
LDX #$12
+
STX $0F

INC $01

LDA $05
CMP #$01
BEQ .raise
CMP #$04
BEQ .raise
CMP #$07
BEQ .raise
BRA .noraise
.raise
DEC $01
.noraise
LDA #$A0
TSB $0412
LDA #$0A			;set tile size designations
TRB $0413
LDA #$20
TSB $0413
LDA $00
STA $0300,y
STA $0304,y
LDA $01
STA $0305,y
SEC
SBC #$10
STA $0301,y
LDA #$22
STA $0302,y
LDA #$20
STA $0306,y
LDX $0F65
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

JSR Draw_Eights

LDA $0DB9
AND #$18
CMP #$10
BNE +
JSR Cape_Frame
JSR Draw_Cape
+

LDY #$FF
LDA #$03
JSL $01B7B3
RTS

Draw_Eights:
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
LDA $01
CLC
ADC #$05
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

Cape_Frame:
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

Draw_Cape:
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GET_DRAW_INFO
; This is a helper for the graphics routine.  It sets off screen flags, and sets up
; variables.  It will return with the following:
;
;		Y = index to sprite OAM ($300)
;		$00 = sprite x position relative to screen boarder
;		$01 = sprite y position relative to screen boarder
;
; It is adapted from the subroutine at $03B760
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPR_T1:             db $0C,$1C
SPR_T2:             db $01,$02

GET_DRAW_INFO:      STZ $186C,x             ; reset sprite offscreen flag, vertical
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


GETSLOT:		;Y=0: foot Y=1: head
	PHA
	TYA
	ASL
	PHA
	LDA #$01
	JSR GetCharacter
	TAY
	LDA.w CharOffsets,y
	STA $0F
	PLY
	PLA
	CLC
	ADC $0F
	JSR TileToAddr
	STA $0F44,y
	SEP #$20
	RTS




;;;;;;;;;
;
;Draw Bubble
;
;;;;;;;;;

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

;;;;;;;;;
;
;Calculate Frame
;
;;;;;;;;;

CalcFrame:
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
BNE  .moving
.stationary
LDA $1588,x
BIT #$04
BEQ +
LDA $0DA3
BIT #$03
BNE .moving
+
STZ $05
RTS
.climbthing
LDA #$10
STA $05
RTS
.underwater
LDA $1588,x
BIT #$04
BNE -
LDA $151C,x
AND #$0F
CMP #$0C
BCC +
LDA #$1A
STA $05
RTS
+
CMP #$04
BCC +
LDA #$1B
STA $05
RTS
+
LDA #$1C
STA $05
RTS
.dead
LDA #$15
STA $05
RTS
.bubble
LDA #$14
STA $05
RTS
.turnaround
LDA #$0E
STA $05
RTS
.kickthing
LDA #$13
STA $05
RTS
.lookupdown	;A=$0DB9
LSR #5
AND #$01
CLC
ADC #$0C
STA $05
RTS
.inair
JMP .inairh
.fireball
LDA $1588,x
BIT #$04
BEQ +
LDA #$0F
STA $05
RTS
+
LDA #$18
STA $05
RTS
.peace
LDA #$11
STA $05
STZ $AA,x
STZ $B6,x
RTS
.moving
LDA $151C,x			;\ if there is still time remaining on this frame
BNE .movesame		;/ reuse last frame
JSR RunOCSet		;else, figure out how long next frame should be based on speed, store to $151C
LDA $1510,x			;load previous frame
BRA +
--
LDA #$00			;goto first walk frame
BRA .sprintshift
+
CMP #$03
BCC +
SEC
SBC #$03
+
CMP #$02			;if not a walk/run frame
BCS --
INC
.sprintshift
TAY
LDA $163E,x
CMP #$70
BCC +
INY #3
+
TYA
STA $05
.return
RTS
.movesame
LDA $1510,x
CMP #$06
BCS --
STA $05
RTS

.inairh
LDA $0DB9
BIT #$01
BNE .spinjump
LDA $0F6A
BIT #$01
BNE .bjsj
LDA $AA,x
BMI .upjump
LDA #$14
STA $05
RTS
.upjump
LDA #$09
STA $05
RTS
.bjsj
LDA #$19
STA $05
RTS
.SJFS
db $00,$00,$0A,$0A,$00,$00,$0B,$0B
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
STA $05
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



;;;;;;;;;
;
;Calculate Direction:
;
;;;;;;;;;

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


;;;;;;;;;;;;;;;
;;
;;  Get Pointer to current palette data
;;  Arguments: which player, in A
;;
;;;;;;;;;;;;;;;

GetPaletteP1:
    SEP #$20
    LDA $0F63
    BIT #$03
    BEQ .totesRegular
    LDA $71                    ; Check current animation
    CMP #$04
    BEQ FireFlashPalette
    LDA $1490                    ; Check if has star
    BNE StarFlashPalette
    LDA $19
    CMP #$03                    ; Check if fire
    BNE .totesRegular
    REP #$20
    LDA #$B304
    RTS
    .totesRegular
    LDA #$00
    JMP UniversalEnd

    FireFlashPalette:
    LDA $13
    LSR
    BRA BothFlashPalette

    StarFlashPalette:
    LDA $14
    ASL

    BothFlashPalette:
    REP #$20
    AND #$001E
    CLC
    ADC #$B2C0
    RTS

GetPaletteP2:
    SEP #$20
    LDA $0F63
    BIT #$0C
    BEQ .totesRegular
    LDY $0F65
    LDA $1504,y                ; Check current animation
    CMP #$08
    BEQ FireFlashPalette
    LDA $1570,y                ; Check if has star
    BNE StarFlashPalette
    LDA $0DB9                    ; Check if fire
    AND #$18
    CMP #$18
    BNE .totesRegular
    REP #$20
    LDA #$B304
    RTS
    .totesRegular
    LDA #$01

    UniversalEnd:
    JSR GetCharacter
    ASL
    PHX
    TAX
    REP #$20
    LDA $00E2AA,x            ; Load from list of pointers to different palettes
    PLX
    RTS


OWPindex:
db $00,$0A,$14

OWPalettes:
dw $3739,$4FDE,$20BA,$2D1E,$459E
dw $217A,$32DE,$3414,$4997,$0000
dw $6AD6,$77BD,$456F,$5A35,$66FD

OWDynams:
db $02,$03,$00,$01,$04,$05,$04,$05
db $02,$03,$00,$01,$04,$05,$04,$05
db $06,$06,$06,$06,$07,$07,$07,$07

!WATERTILESADDR = $78C0

OWOAM:
    LDA #$F0
    STA $02A1       ; futz with (make invisible) a whole lot of OAM addresses
    STA $02A5
    STA $02A9
    STA $02AD
    STA $02C1
    STA $02C5
    STA $02C9
    STA $02CD
    STA $02D1

    STZ $029E		;player 1 tile
    LDA #$02
    STA $02BE		;player 2 tile
    LDA #$80
    TSB $0409        ; \  set 16x16-ness?
    TSB $040B        ; /

        ; Set up addresses to DMA graphics and palettes from

    LDA #$00
    JSR GetCharacter
    TAX
    LDA.l OWPindex,x
    REP #$20
    AND #$00FF
    CLC
    ADC.w #OWPalettes
    STA $0F3A
    PHK
    PLY
    STY $0F3C
    STY $0F44

    SEP #$20
    LDA #$01
    JSR GetCharacter
    TAX
    LDA.l OWPindex,x
    REP #$20
    AND #$00FF
    CLC
    ADC #OWPalettes
    STA $0F42


    SEP #$20                     ; \
    LDA $14                      ;  |
    AND #$08                     ;  |
    LSR #3                       ;  |
    ORA $1F13                    ;  |
    PHX                          ;  | Pick out pose
    TAX                          ;  |
    LDA.l OWDynams,x             ;  |
    PLX                          ;  |
    CLC                          ;  |
    ADC #$90                     ;  |
    STA $00                      ; /

    LDA #$00
    JSR GetCharacter
    ASL #3
    CLC
    ADC $00
    JSR TileToAddr
    STA $0F3D
    SEP #$20
    LDA #$7E
    STA $0F3F
    STA $0F47

    LDA #$01
    JSR GetCharacter
    ASL #3
    CLC
    ADC $00
    JSR TileToAddr
    STA $0F45
    SEP #$20
    RTS
