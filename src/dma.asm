pushpc
org $00A300
JML BEGINDMA
pullpc

OWEdgeCase:
LDA $141A
BNE ContinUpload
LDA $71
CMP #$0A
BEQ ContinUpload
OWUploadJmp:
JMP OWUpload

BEGINDMA:
SEP #$20
LDA $0100
CMP #$0E
BEQ OWUploadJmp
CMP #$0D
BEQ OWUploadJmp
CMP #$0F
BEQ OWEdgeCase
CMP #$14
BEQ ContinUpload
CMP #$07
BEQ ContinUpload
CMP #$13
BEQ ContinUpload
ReStop:
JMP DoNone
ContinUpload:

LDA $010A
BRA +
-
SEC
SBC #$03
+
CMP #$03
BCS -
STA $010A
REP #$20
LDX #$04				; All DMA is on channel 2 - STX $420B sets off

;;
;Set up DMA settings for palette writes
;;

LDY #$00				;from bank 0
STY $4324
LDA #$2200				;DMA to $2122 - CGRAM write data - 1 reg write once
STA $4320				;DMA channel #2 - $432x

;;
;Mario's Palette
;;

LDY #$86				;CGRAM write address  - start writing at palette 8 color A (mario's stuff)
STY $2121
JSR GetPaletteP1
STA $4322 				;DMA read address
LDA #$0014				;14 bytes of data
STA $4325
STX $420B				; Execute DMA

LDY $0DB3
BEQ .skip1

;;
;Luigi's Palette
;;

LDY #$96				;CGRAM write address  - start writing at palette 9 color A (luigi's stuff)
STY $2121
JSR GetPaletteP2
STA $4322				;DMA read address
LDA #$0014				;14 bytes of data
STA $4325
STX $420B				; Execute DMA

;;
;Setup for 8x8 DMA
;;

.skip1

LDY #$80
STY $2115                ; Set DMA to handle 16-bit values
LDA #$1801
STA $4320
PHK
PLY
STY $4324                ; Bank to DMA from - current code bank

;;
;Mario's 8x8 tiles
;;

LDA #$60A0
STA $2116                ; VRAM address
LDA $0F3A
STA $4322                ; RAM address to DMA from
LDA #$0040
STA $4325                ; Some flag, idk
STX $420B        ; Execute DMA

LDY $0DB3
BEQ .skip2

;;
;Luigi's 8x8 tiles
;;

LDA #$61A0                ; VRAM address
STA $2116
LDA $0F42
STA $4322
LDA #$0040
STA $4325
STX $420B

.skip2

;;
;Upper halves of Mario's tiles
;;

LDA #$6000
STA $2116
LDX #$00
.loop
LDA $0F3C,x
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX $0D84
BCC .loop

;;
;Lower halves of Mario's tiles
;;

LDA #$6100
STA $2116
LDX #$00
.loop2
LDA $0F3C,x
CLC
ADC #$0200
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX $0D84
BCC .loop2

LDY $0DB3
BEQ .skip3

;;
;Upper halves of Luigi's tiles
;;

if !SEPERATEGFX && !!THREEPLAYER
LDA.l SeperatePointer+2
TAY
else
LDY #$7E
endif
STY $4324

LDA #$6200
STA $2116
LDX #$00
.loop3
LDA $0F44,x
STA $4322
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX #$04
BCC .loop3

;;
;Lower halves of Luigi's tiles
;;

LDA #$6300
STA $2116
LDX #$00
.loop4
LDA $0F44,x
CLC
ADC #$0200
STA $4322
;LDY #$7E
;STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B
INX #2
CPX #$04
BCC .loop4

.skip3

;;
;Mario's cape tile
;;

LDY $19
CPY #$02
BNE .nocapemario

LDA #$6040
STA $2116
LDA $13DF
AND #$000F
ASL
TAY
LDA.w CapeAddresses,y
STA $4322
PHA                      ; Save cape address
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B                ; Execute DMA 1 - top row

LDA #$6140
STA $2116
PLA                      ; Recover cape address
CLC
ADC #$0200               ; Advance to next 8x8 line
STA $4322
LDY #$7E
STY $4324
LDA #$0040
STA $4325
LDY #$04
STY $420B                ; Execute DMA 2 - bottom row

.nocapemario

;;
;Luigi's cape tile
;;

SEP #$20
LDA $0DB2
BEQ .nocapeluigi
LDA $0DB9
AND #$18
CMP #$10
BNE .nocapeluigi

if !SEPERATEGFX && !!THREEPLAYER
LDA.l SeperatePointer+2
TAY
else
LDY #$7E
endif
STY $4324

LDX $0F65
REP #$20
LDA #$6060
STA $2116
LDA $1534,x
AND #$000F
ASL
TAY
LDA.w CapeAddresses,y
STA $4322
PHA
LDA #$0040
STA $4325
LDY #$04
STY $420B                ; Execute DMA 1 - Top row

LDA #$6160
STA $2116
PLA
CLC
ADC #$0200
STA $4322
LDA #$0040
STA $4325
LDY #$04
STY $420B                ; Execute DMA 2 - Bottom row

.nocapeluigi

DoNone:
SEP #$30
JML $80A38F


OWUpload:
REP #$20
LDX #$04

LDY #$B8             ; \
STY $2121            ;  |
LDY #$3B             ;  | Write to CGRAM B8 -- the bg color for the walking-mario area?
STY $2122            ;  |
LDY #$57             ;  |
STY $2122            ; /

LDA $0F3A
CMP #$FFFF            ; Cancel all uploads if necessary
BEQ DoNone

;;
;Mario palette
;;

LDA $0F3A                 ;Upload address
STA $4322
LDY $0F3C                 ;Upload bank
STY $4324
LDA #$2200				;DMA to $2122 - CGRAM write data - 1 reg write once
STA $4320		 		;DMA channel #2 - $432x
LDY #$A3			  	;CGRAM write address  - start writing at palette A color 3
STY $2121
LDA #$000A				;14 bytes of data
STA $4325
STX $420B

;;
;Luigi palette
;;

LDA $0F42                 ;Upload address
STA $4322
LDY $0F44                 ;Upload bank
STY $4324
LDA #$2200				;DMA to $2122 - CGRAM write data - 1 reg write once
STA $4320			 	;DMA channel #2 - $432x
LDY #$B3			  	;CGRAM write address  - start writing at palette B color 3
STY $2121
LDA #$000A				;14 bytes of data
STA $4325
STX $420B

;;
;Mario tile - top row
;;

LDY #$80
STY $2115
LDA #$6000
STA $2116
LDA #$1801				;$2118 - 2 regs 1 write
STA $4320
LDA $0F3D
STA $4322
CLC
ADC #$0200
STA $00
LDY $0F3F
STY $4324
LDA #$0040
STA $4325
STX $420B                ; Execute DMA

;;
;Luigi tile - top row
;;

LDA #$0040
STA $4325
LDA $0F45
STA $4322
CLC
ADC #$0200
STA $02
LDY $0F47
STY $4324
STX $420B                ; Execute DMA

;;
;Decide whether to DMA the actual tile or the water bottoms instead
;;

if !THREEPLAYER
SEP #$20
LDA $1F13
CMP #$12
BEQ .waterbottom
SEC
SBC #$08
CMP #$08
BCS .regularbottom
.waterbottom
LDA $14
REP #$20
AND #$0008
BEQ +
LDA #$0200
+
CLC
ADC #!WATERTILESADDR
STA $00
STA $02

.regularbottom
endif

;;
;Mario tile - bottom row
;;

REP #$20
LDY #$80
STY $2115
LDA #$6100
STA $2116
LDA #$1801				;$2118 - 2 regs 1 write
STA $4320
LDA $00
STA $4322
LDY $0F3F
STY $4324
LDA #$0040
STA $4325
STX $420B                ;Execute DMA

;;
;Luigi tile - bottom row
;;

LDA #$0040
STA $4325
LDA $02
STA $4322
STX $420B                 ;Execute DMA

JMP DoNone
