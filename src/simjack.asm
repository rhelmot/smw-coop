;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Hijacks from afterthoughs.asm;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $048F93
db $00				;save after every level

org $02AEF4
RTS					;don't show glitched 'coin'

org $00F384			;score routine something
LDA #$13

org $00F878			;looks like some sort of attempt to always scroll w/ mario
BRA $07

org $00D10A			;prevent problems after mario death
NOP
NOP

org $03AA6E			;prevent some sprite from writing to OAM?
RTS

org $009767			;game over at proper times
LDA $0DB4
ORA $0DB5
BPL $19
NOP #8

org $028AD2
INC $0DB4

;FastROM registration data
org $7FD5
db $30

org $00DF1A
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00		;remapping that came with one of the DMA patches I assimilated
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$28,$00
db $00

db $00,$00,$00,$00,$04,$04,$04,$00
db $00,$00,$00,$00,$04,$00,$00,$00
db $00,$04,$04,$04,$00,$00,$04,$04
db $04,$04,$04,$04,$00,$00,$04,$00
db $00,$00,$00,$04,$00,$00,$00,$00
db $04,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00

db $00,$00,$00,$00,$04,$04,$04,$00
db $00,$00,$00,$00,$04,$00,$00,$00
db $00,$04,$04,$04,$00,$00,$04,$04
db $04,$04,$04,$04,$00,$00,$04,$00
db $00,$00,$00,$04,$00,$00,$00,$00
db $04,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00

org $00DFDA
db $00,$02,$0A,$0B		;[00-03]
db $00,$02,$0A,$0B		;[04-07]
db $00,$00,$00,$00		;[08-0B]
db $00,$00,$00,$00		;[0C-0F]
db $00,$00,$00,$00		;[10-13]
db $00,$00,$00,$00		;[14-17]
db $00,$00,$00,$00		;[18-1B]
db $00,$00,$00,$00		;[1C-1F]
db $00,$00,$00,$00		;[20-23]
db $00,$00,$00,$00		;[24-27]
db $00,$02,$02,$80		;[28-2B]
db $04,$7F				;[2C-2D]
db $4A,$5B,$4B,$5A		;[2E-31]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Hijacks to free up Luigi RAM;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;$0DB3

org $0086A5
LDX #$00
NOP

;stuff in status bar routine skilled

org $0091D8			;Luigi start?
LDA #$00
NOP

org $009E5F			;STZ $0DB3 - probably game INIT or something
NOP #3

org $00A0BC		;Probably lives on OW border...?
LDX #$00
NOP
LDA $0DB4

org $00A12A			;OW drawing thing
LDX #$00
NOP

;org $00E317		;player palette - $0D82 is unused now, right?
;NOP #3

org $01E2F3				
LDY #$00
NOP

org $01EC29
LDY #$00
NOP

org $028758			;score
LDX #$00
NOP #6

org $02AE12
LDX #$00
NOP #6				;also score

org $02DA79
LDY #$00
NOP

org $0392F8
LDY #$00
NOP

org $048375
LDX #$00
NOP

org $048509
LDY #$00
NOP

;A couple of spots where it appears $0DB3 was only being used to access $0DB4/5 in 16-bit

org $048E3A
LDX #$00
NOP

org $048E57
LDA #$0000

org $0491B5
LDA #$02
STA $0DB1
LDA #$80
STA $1DFB
INC $0100
RTS

org $049334
LDA #$0000

org $049D9F
LDA #$00
NOP

org $049DD1
JMP $9DFD

org $049E08
LDX #$00
NOP

org $04EB3A
LDX #$00
NOP

org $04F51D
LDX #$00
NOP

org $04FD79
LDY #$00
NOP

org $05CC68
LDX #$00
NOP

org $05CCB1
LDA #$00
NOP

org $05CED1
LDA #$0000

org $05CF12
LDX #$00
NOP

org $05DC03
LDA #$00
NOP

;;;$0DB9

