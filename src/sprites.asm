Sprites:
LDA $0F60
STA $142C
LDA #$FF
STA $0F60

LDX #$0B		;Load # of sprites
INTRLOOP:					;Loopstart above get-self-clipping so moar scratch ram can be used (TODO very inefficient)
CPX $0F65
BEQ NEXTSPR
LDA $14C8,x
CMP #$08
BCC NEXTSPR
LDA $154C,x
BNE NEXTSPR

JSR GetSpriteClip
JSR UpdateSpriteDeltas

JSR ClipWithMe
BCC NEXTSPR		;if no contact, continue loop

LDA $0DB9

; if debug mode is enabled, put the sprite number we're touching on the status bar
BIT #$40
BEQ +
LDA $9E,x
PHA
AND #$0F
STA $0EFA
PLA
LSR #4
STA $0EF9
+

TXY			;client sprite index to Y
JSR SpriteInteract	;interact
TYX			;client back to X
NEXTSPR:
DEX			;next sprite
BPL INTRLOOP		;If done, end
INTREND:
LDX $0F65
RTS

; Load the clipping for the current sprite. stores:
;   $04 = xpos low byte
;   $05 = ypos low byte
;   $06 = xsize
;   $07 = ysize
;   $0A = xpos high byte
;   $0B = ypos high byte
GetSpriteClip:
LDA $9E,x
CMP #$5F
BNE +
JMP BrownRotatingPlatformClip

+
CMP #$59
BNE +
-
JMP GetTurnBrdgClip
+
CMP #$5A
BEQ -

CMP #$62
BNE +
-
JMP MovingPlatClip
+
CMP #$63
BEQ -

CMP #$A3
BNE +
JMP GreyRotatingPlatformClip

+
JSL $83B69F		; default clipping routine
RTS


; Update the custom $7FAC60-etc tables
; Then if luigi is riding this sprite update his position
UpdateSpriteDeltas:
LDA $05
PHA
SEC
SBC $7FAC78,x
STA $7FAC60,x
PLA
STA $7FAC78,x

LDA $04
PHA
SEC
SBC $7FAC84,x
STA $7FAC6C,x
PLA
STA $7FAC84,x

CPX $142C
BNE .notRiding
LDY $0F65

STZ $00
LDA $7FAC60,x
BPL +
DEC $00
+
CLC
ADC $00D8,y
STA $00D8,y
LDA $14D4,y
ADC $00
STA $14D4,y

STZ $00
LDA $7FAC6C,x
BPL +
DEC $00
+
CLC
ADC $00E4,y
STA $00E4,y
LDA $14E0,y
ADC $00
STA $14E0,y

.notRiding
RTS

; Load luigi's clipping. stores:
;   $00 = xpos low byte
;   $01 = ypos low byte
;   $08 = xpos high byte
;   $09 = ypos high byte
ClipWithMe:		;Uses: $00,$01,$02,$03,$08,$09
PHX
LDX $0F65
JSR GetHeight
TAY
LDA $E4,x
STA $00                   ; $00 = (Sprite X position + displacement) Low byte
LDA $14E0,x
STA $08                   ; $08 = (Sprite X position + displacement) High byte
LDA #$10                  ; $02 = Clipping width
STA $02
LDA $D8,x
SEC
SBC.w .tentwenty,y
STA $01                   ; $01 = (Sprite Y position + displacement) Low byte
LDA $14D4,x
SBC #$00
STA $09			  ; $09 = (Sprite Y position + displacement) High byte
LDA.w .negtentwenty,y                  ; $03 = Clipping height
STA $03
JSL $83B72B
PLX
RTS

.tentwenty
db $00,$10

.negtentwenty
db $10,$20

GetTurnBrdgClip:
LDA $C2,x
AND #$02
BNE .vertical
LDA $D8,x
STA $05
LDA $14D4,x
STA $0B
LDA #$10
STA $07
LDA $E4,x
SEC
SBC $151C,x
STA $04
LDA $14E0,x
SBC #$00
STA $0A
LDA $151C,x
ASL
CLC
ADC #$10
STA $06
RTS
.vertical
LDA $E4,x
STA $04
LDA $14E0,x
STA $0A
LDA #$10
STA $06
LDA $D8,x
SEC
SBC $151C,x
STA $05
LDA $14D4,x
SBC #$00
STA $0B
LDA $151C,x
ASL
CLC
ADC #$10
STA $07
RTS

MovingPlatClip:
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
SEC
SBC #$0020
SEP #$20
STA $04
XBA
STA $0A
LDA #$30
STA $06
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
SEC
SBC #$0008
SEP #$20
STA $05
XBA
STA $0B
LDA #$10
STA $07
RTS

BrownRotatingPlatformClip:
LDA $164A,x
XBA
LDA $1588,x
REP #$20
STA $00
LDA #$0080
SEC
SBC $00
AND #$01FF
STA $00
SEP #$20
LDA #$50
STA $0D
LDA #$38
STA $0E
JSR GenericRotatingPlatformClip
LDA $04
SEC
SBC #$58
STA $04
LDA $0A
SBC #$00
STA $0A
LDA $05
SEC
SBC #$10
STA $05
LDA $0B
SBC #$00
STA $0B
RTS


GreyRotatingPlatformClip:
LDA $151C,x		; 0 = rising, 1 = falling
STA $01
LDA $1602,x		; low angle - when it hits ff 151C toggles
STA $00                 ; $00 = full angle
LDA $187B,x
STA $0D
LDA #$28
STA $0E
JMP GenericRotatingPlatformClip

; Calculate clipping for a rotating platform. input:
;   $00[16] = angle, 0 = down, increasing counterclockwise
;   $0D[8] = radius
;   $0E[8] = width
; this code adapted from $02D62A-ish
GenericRotatingPlatformClip:
PHX			; 0 = down, 80 = right, 100 = up, 180 = left
REP #$30
LDA $00
CLC
ADC #$0080
AND #$01FF
STA $02			; tweak angle - 0 = left, 80 = down, 100 = right, 180 = up

LDA $00
AND #$00FF
ASL
TAX
LDA $07F7DB,x		; index into the sine table with only the low part of the angle
STA $04			; into 04 and 06 for the two angles respectively

LDA $02
AND #$00FF
ASL
TAX
LDA $07F7DB,x
STA $06

	; $04 = sin(theta) * 0x100
	; $06 = cos(theta) * 0x100

SEP #$30
PLX			; X = Sprite index

LDA $04
STA $4202               ; Multiply circle coordinate 1...
LDA $0D
LDY $05			; (if 05 is 1 then the sine is #$100, special case)
BNE +
STA $4203		; ... by sprite radius (#$30 for gray plat)
NOP #8
ASL $4216
LDA $4217               ; Take the high byte of the result
ADC #$00		; ... plus 1 if the low byte is >#$7f (round to nearest)
+
LSR $01			; if the original angle is >#$ff, negate the result
BCC +
EOR #$FF
INC A
+
STA $04

LDA $06
STA $4202               ; Multiplicand A
LDA $0D
LDY $07
BNE +
STA $4203               ; Multplier B
NOP #8         ; wait for multiplication to complete
ASL $4216               ; Product/Remainder Result (Low Byte)
LDA $4217               ; Product/Remainder Result (High Byte)
ADC #$00
+
LSR $03
BCC +
EOR #$FF
INC A
+
STA $06

; goal: compute $04:$0A = sprite.x + $04 + #$0008 - (width >> 1)

STZ $05
LDA $04
BPL +
DEC $05		; set $05 to sign of $04
+

STZ $0F
LSR $0E
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
SEC
SBC $0E
CLC
ADC $04
CLC
ADC #$0008
SEP #$20
STA $04
XBA
STA $0A


; round 2: compute $05:$0B = sprite.y + $06 - #$0002

STZ $07
LDA $06
BPL +
DEC $07
+

LDA $14D4,X
XBA
LDA $D8,X
REP #$20
CLC
ADC $06
SEC
SBC #$0002
SEP #$20
STA $05
XBA
STA $0B

LDA $0E
ASL
STA $06
LDA #$10
STA $07
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SpriteInteract
;
; The big boy! The grand master of the circus ring!
; :)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteInteract:
LDA $009E,y		;\client sprite #
REP #$30		; |set 16 bit A
AND #$00FF		; |clear high byte
ASL			; |double
TAX
LDA.w Ptr,x
STA $00			; |store to scratch
SEP #$30		; |8 bit A
LDX $0F65
JMP ($0000)		;/Jump to correct interaction routine

Ptr:	;Enemy Names Added and fixed interactions :)
DW Sprite00    ;Green Koopa No Shell	-Old
DW Sprite00    ;Red Koopa No Shell	-Old
DW Sprite00    ;Blue Koopa No Shell	-Old
DW Sprite00    ;Yellow Koopa No Shell	-Old

DW Sprite04    ;Green Koopa	-Old
DW Sprite04    ;Red Koopa	-Old
DW Sprite04    ;Blue Koopa	-Old
DW Sprite04    ;Yellow Koopa	-Old

DW Sprite08    ;Green Koopa Flying Foward	-Old

DW Sprite09    ;Green Bouncing ParaKoopa	-Old

DW Sprite0A    ;Red Vertical ParaKoopa	-Old

DW Sprite0B    ;Red Horizontal ParaKoopa	-Old

DW Sprite0C    ;Yellow ParaKoopa doesn't fly	-Old

DW Sprite0F    ;Bob-omb	-New

DW MadeNone      ;KeyHole	-Old

DW Sprite0F    ;Goomba	-New

DW Sprite10    ;Bouncing ParaGoomba	-New

DW Sprite0F;   ;Buzzy-Bettle	-New

DW Sprite12    ;Unused

DW Sprite4F    ;Spiny	-Fixed

DW Sprite4F    ;Falling Spiny	-Fixed

DW Sprite4F    ;Fish Horizontal	-Old

DW Sprite4F    ;Fish Vertical	-Old

DW Sprite47    ;??????

DW Sprite4F    ;Surface Jumping Fish	-Old...Need Fixes

DW MadeNone      ;Display Level Message 1

DW Sprite4F    ;Classic Piranha Plant	-New

DW Sprite1C    ;Bouncing Bootball in Place	-New

DW Sprite1C    ;Bullet Bill	-New

DW Sprite4F    ;Hopping Flame	-Fixed

DW Sprite1C    ;Lakitu Normal/Fish	-New

DW Sprite1F    ;Magikoopa	-New

DW Sprite4F    ;Magikoopa's Magic	-Old

DW Sprite21    ;Moving Coin	-Fixed bug when you got 100 coins with this sprite...bugs the counter

DW Sprite22    ;Green Vertical Net Koopa	-Fixed

DW Sprite23    ;Red Fast Vertical Net Koopa	-Fixed

DW Sprite24    ;Green Horizontal Net Koopa	-Fixed

DW Sprite25    ;Red Fast Horizontal Net Koopa	-Fixed

DW Sprite4F    ;Thwomp	-Old

DW Sprite4F    ;Thwimp	-Old

DW Sprite4F    ;Big Boo	-Old

DW Sprite29    ;Koopa Kid

DW Sprite4F    ;Upside Down Piranha Plant	-Fixed

DW Sprite4F    ;Sumo Brother Light	-Fixed

DW MadeNone      ;Yoshi Egg

DW MadeNone      ;Baby Green Yoshi

DW Sprite4F    ;Spike Top	-Old

DW Sprite2F    ;Portable SpringBoard	-Need Fixes

DW Sprite30    ;DryBones ThrowBones	-New

DW Sprite30    ;Bony Bettle	-Need Fixes

DW Sprite30    ;DryBones	-New

DW Sprite4F    ;Podoboo	-Old

DW Sprite4F    ;Boss FireBall	-Old

DW MadeNone    ;Green Yoshi

DW Sprite36    ;??????

DW Sprite4F    ;Boo	-Old

DW Sprite4F    ;Eerie	-Old

DW Sprite4F    ;Eerie Wave Motion	-Old

DW Sprite4F    ;Urchin, Fixed Vertical/Horizontal	-Old

DW Sprite4F    ;Urchin, Wall detect	-Old

DW Sprite4F    ;Urchin, Wall Follow	-Old

DW Sprite4F    ;Rip van Fish	-Old

DW Sprite3E    ;P-Switch Blue/Grey	-Fixed

DW Sprite10    ;Para Goomba	-New

DW Sprite41    ;Para Bomb	-New

DW Sprite55    ;Dolphin, Long Jump Horizontal	-New

DW Sprite55    ;Dolphin2, Short Jump Horizontal	-New

DW Sprite55    ;Dolphin, Jump Vertical	-New

DW Sprite4F    ;Torpedo Ted	-New

DW MadeNone    ;Directional Coin

DW Sprite91    ;Diggin Chuck	-Old

DW Sprite47    ;Swiming Jumping Fish

DW Sprite4F    ;Diggin Chuck's rock	-Old

DW Sprite6D    ;Growing Pipe	-New

DW Sprite4A    ;Goal Point Question Sphere	-Need Fixes

DW Sprite1C    ;Pipe Lakitu	-New

DW Sprite6D    ;Exploding Block	-New

DW Sprite4D    ;Ground Mole	-Old

DW Sprite4E    ;Ledge Mole	-Old

DW Sprite4F    ;Jumping Piranha	-Old

DW Sprite4F    ;Jumping Piranha Spit Fire	-Old

DW Sprite1C    ;Ninji	-New

DW Sprite52    ;Moving Hole

DW Sprite53    ;Purple TurnBlock

DW MadeNone    ;Climbing Net

DW Sprite55    ;CheckBoard Plataform Horizontal	-Old

DW Sprite55    ;FlyingRock Plataform Horizontal	-New

DW Sprite55    ;CheckBoard Plataform Vertical	-Old

DW Sprite55    ;FlyingRock Plataform Vertical	-New

DW Sprite59    ;TurnBlock Bridge Horizontal And Vertical	-Old

DW Sprite5A    ;TurnBlock Bridge Horizontal	-Old

DW Sprite55    ;Brown Floating in water Plataform	-Need Fixes

DW Sprite5C    ;Checker Floating in water Plataform	-Need Fixes

DW Sprite5D    ;Orange Plataform Floating in water	-Old

DW Sprite5D    ;Big Orange Plataform Floating in water	-New

DW Sprite5F    ;Brown Plataform on a chain	-Old

DW Sprite6D    ;Flat Green Switch	-New

DW Sprite61    ;Floating Skulls	-New!

DW Sprite62    ;Brown Plataform Line-Guided	-Old

DW Sprite63    ;Checker/Brown Plataform Line-Guided	-Old

DW Sprite64    ;Rope Mechanism, Line Guided

DW Sprite4F    ;Chainsaw, Line Guided, UP	-Old

DW Sprite4F    ;Chainsaw, Line Guided, Down	-Old

DW Sprite4F    ;Grinder, Line Guided	-Old

DW Sprite4F    ;Fuzz Ball	-Old

DW Sprite69    ;??????

DW Sprite6A    ;Coin Game Cloud

DW Sprite55    ;Spring Board, Left Wall

DW Sprite55    ;Spring Board, Right Wall

DW Sprite6D    ;Invisible Solid Block	-Old

DW Sprite6E    ;Dino Rhino	-New

DW Sprite00    ;Dino Torch	-Need Check he's fire

DW Sprite70    ;Pokey	-Old

DW Sprite71    ;Super Koopa, Red Cape, Swoop	-Old

DW Sprite72    ;Super Koopa, Yellow Cape, Swoop	-Old

DW Sprite73    ;Super Koopa, Feather/Yellow Cape, Swoop	-Old

DW Sprite74    ;Mushroom	-Fixed(save items in itembox)

DW Sprite75    ;FireFlower	-Fixed(save items in itembox)

DW Sprite76    ;Star	-Old

DW Sprite77    ;Feather	-Fixed(save items in itembox)

DW Sprite78    ;1-UP	-Old

DW MadeNone    ;Growing-Vine

DW MadeNone    ;Firework

DW Sprite7B    ;\Goal Point	-Old
DW Sprite7C    ;/

DW Sprite7D    ;P-Ballon

DW Sprite7E    ;Flying Red Coin	-New

DW Sprite78    ;Flying Golden 1-UP	-Old

DW Sprite80    ;Key	-Need Fixes

DW Sprite81    ;Changing Item	-Old...Need Fixes

DW Sprite82    ;Bonus game thing	-Old...Need Fixes

DW Sprite83    ;Left Flying Question Block	-Old

DW Sprite83    ;Flying Question Block	-New

DW Sprite85    ;??????

DW Sprite86    ;Wiggler

DW MadeNone    ;Lakitu Cloud

DW Sprite88    ;??????

DW MadeNone    ;Layer 3 Smash

DW MadeNone    ;Yoshi House Bird

DW MadeNone    ;Yoshi House Smoke

DW MadeNone    ;Side Exit Enable/Yoshi House Smoke Generator

DW MadeNone    ;Ghost House Exit And Door

DW Sprite8E    ;Invisible "Warp Hole" Blocks	-Old

DW Sprite8F    ;Scale Plataform

DW Sprite70    ;Large Green Gas Bubble	-New

DW Sprite91    ;Chargin'Chuck
DW Sprite91    ;Splittin'Chuck
DW Sprite91    ;Bouncin'Chuck
DW Sprite91    ;Whistlin'Chuck
DW Sprite91    ;Clappin'Chuck
DW Sprite91    ;Puntin'Chuck
DW Sprite91    ;Pitchin'Chuck
DW Sprite91    ;Chargin'Chuck

DW Sprite4F    ;Volcano Lotus	-Old

DW Sprite4F    ;Sumo Brother	-New

DW Sprite1C    ;Amazing Flying Hammer Brother	-New

DW Sprite9C    ;Blocks for Amazing Flying Hammer Brother	-New

DW Sprite9D    ;Bubble With Goomba/Bomb/Fish/Mushroom	-New

DW Sprite6D    ;Ball'n Chain

DW Sprite9F    ;Banzai Bill	-Old

DW SpriteA0    ;Activate Bowser Scene

DW Sprite70    ;Bowser's Bowling Ball	-New

DW Sprite0F    ;MechaKoopa	-New

DW SpriteA3    ;Grey Plataform On A Chain	-Old

DW Sprite4F    ;Floating Spike Ball	-New

DW Sprite4F    ;Spark Fuzz Ball Ground-Guided	-Old

DW Sprite4F    ;Hot Head Ground-Guided	-Old

DW Sprite4F    ;??????

DW Sprite4F    ;Blargg	-Old

DW Sprite1C    ;Reznor	-New

DW Sprite4F    ;Fish Bone	-Old

DW SpriteAB    ;Rex	-Old

DW SpriteAC    ;Wooden Spike, Moving Down And Up

DW SpriteAD    ;Wooden Spike, Moving Up And DOwn

DW Sprite4F    ;Fishin Boo	-Old

DW Sprite6D    ;BooBlock	-Old

DW Sprite4F    ;Reflecting Stream Of Boo Boddies	-Old

DW Sprite6D    ;Creating/Eating Block	-New

DW Sprite4F    ;Falling Spike	-New

DW Sprite4F    ;Bowser Statue FireBall	-Old

DW Sprite4F    ;Grinder Non-Line-Guided	-Old

DW Sprite4F    ;??????

DW Sprite4F    ;Reflecting FireBall	-Old

DW Sprite55    ;Carrot Top Lift, Upper Right	-Need Fixes...

DW Sprite55    ;Carrot Top Lift, Upper Left	-Need Fixes...

DW SpriteB9    ;Info Box	-Old

DW SpriteBA    ;Timed Lift 4/1 Seconds	-New

DW SpriteBB    ;Grey Moving Castle Block	-New

DW SpriteBC    ;Bowser Statue	

DW Sprite00    ;Sliding Koopa Without a Shell	-Old

DW Sprite23    ;Swooper Bat	-Old

DW SpriteBF    ;Mega Mole	-New

DW Sprite5D    ;Gray Plataform On Lava	-New

DW SpriteC1    ;Flying Grey Turn Blocks	-New

DW Sprite4F    ;Blurp Fish	-Old

DW Sprite4F    ;A Porchu Buffer Fish	-Old

DW SpriteC4    ;Gray Plataform That Falls	-New

DW MadeNone    ;Big Boo Boss

DW MadeNone    ;Dark room with spot Light

DW SpriteC7    ;Invisible Mushroom	-Old

DW Sprite83    ;Light Switch Block For Dark Room	-New

DW MadeNone    ;Bullet Bill Shooter

DW MadeNone    ;Dolphyn Right Generator

MadeNone:;Do "NONE"
; :v
RTS

Sprite00:;Shelless green koopa and others
LDA $1570,x
ORA $163E,y
BEQ +
JMP KillWithStar
+
LDA $14C8,y
CMP #$08
BNE Gturn
LDA #$00
JSR LocateContact
BEQ GreenWins
LDA $0DB9
AND #$01
BNE GreenSpinKill
LDA #$03
JSR BounceSquash
LDA #$18
STA $1540,y
Gturn:
RTS
GreenSpinKill:
JSR SpinKillSprite
RTS

GreenWins:
JSR HurtLuigi
RTS

;Red shelless koopa = green shelless koopa

;blue shelless koopa = green shelless koopa

;yellow shelless koopa = green shelless koopa

GKoopaWins:
JSR HurtLuigi
RTS

Sprite04:;green koopa
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA $14C8,y
CMP #$09
BNE GKoopaReg
akakaka:
JMP GKoopaShell
GKoopaReg:
LDA #$00
JSR LocateContact
BEQ GKoopaWins
LDA $0DB9
BIT #$01
BEQ Labelname8
JMP SpinKillGreenKoopa
Labelname8:
LDA $14C8,y;bonk by jump
CMP #$0A
BNE Labelname9
JMP KickedShellG;jump if kicked
Labelname9:
LDA #$00
STA $00B6,y
REP #$20
LDA #$FFFC
JSR AddToYpos
;STX $0F
TYX
JSL $02A9DE     ;\Get sprite slot to y
BPL GKoopaGo    ;/if none, return
JMP Labelname7
RTS
GKoopaGo:
LDA #$08        ; \ Sprite status = Normal
STA $14C8,Y     ; /
PHX
LDA $9E,X       ; \ Store sprite number for shelless koopa
TAX             ;  |
LDA $01961C,X   ;  |
STA $009E,Y     ; /
TYX             ; \ Reset sprite tables
JSL $07F7D2     ;  |
PLX             ; /
LDA $E4,X       ; \ Shelless Koopa position = Koopa position
STA $00E4,Y     ;  |
LDA $14E0,X     ;  |
STA $14E0,Y     ;  |
LDA $D8,X       ;  |
STA $00D8,Y     ;  |
LDA $14D4,X     ;  |
STA $14D4,Y     ; /
LDA #$00        ; \ Direction = 0
STA $157C,Y     ; /
LDA #$10
STA $1564,Y
STA $154C,Y
LDA $164A,X
STA $164A,Y
STZ $1540,X
PHX
PHY
JSR ADDR_02D4FA         ; \ Find sprite's position relative to mario
TYX
LDA $0197AD,x       ;  |Load speed based on that
STY $00                   ; / Store index to scratch
PLY
PLX
STA $00B6,Y  ;   set speed
LDA $00                   ; \
EOR #$01                ;  |
STA $157C,Y     ;  |set direction
STA $01                   ; / and set to scratch
LDA #$10                ; \ disable interaction for ten frames
STA $1528,Y  ; /
LDA $9E,X       ; \ If Yellow Koopa...
CMP #$07                ;  |
BNE Labelname7          ;  |
LDY #$08                ;  | ...find free sprite slot...
MCLoop:
LDA $14C8,Y             ;  |
BEQ SpawnMovingCoin       ;  | ...and spawn moving coin
DEY                       ;  |
BPL MCLoop           ; /
Labelname7:
TXY
LDX $15E9
;LDA #$00
;STA $00B6,y
KickedShellG:
LDA #$09
JSR BounceSquash
RTS

SpawnMovingCoin:
LDA #$08                ; \ Sprite status = normal
STA $14C8,Y             ; /
LDA #$21                ; \ Sprite = Moving Coin
STA $009E,Y     ; /
LDA $E4,X       ; \ Copy X position to coin
STA $00E4,Y     ;  |
LDA $14E0,X     ;  |
STA $14E0,Y     ; /
LDA $D8,X       ; \ Copy Y position to coin
STA $00D8,Y     ;  |
LDA $14D4,X     ;  |
STA $14D4,Y     ; /
PHX                       ; \
TYX                       ;  |
JSL $07F7D2    ;  | Clear all sprite tables, and load new values
PLX                       ; /
LDA #$D0                ; \ Set Y speed
STA $00AA,Y  ; /
LDA $01                   ; \ Set direction
STA $157C,Y     ; /
LDA #$20
STA $154C,Y
BRA Labelname7

SpinKillGreenKoopa:
JSR SpinKillSprite
RTS

GKoopaShell:
LDA $0DB9
BIT #$01
BEQ NoSpinGShell
LDA #$00
JSR LocateContact
BNE SpinKillGreenKoopa
NoSpinGShell:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYGK
JSR UpdatePosByCarry
LDA $0DB9
BMI +
LDA #$80
TSB $0DB9
LDA #$08
STA $154C,x
+
RTS
NoXYGK:
LDA $0DB9
BPL KickGShellLR
JSR UpdatePosByCarry
JSR LetGo
RTS
KickGShellLR:
JSR SubHorzPosLuigi
PHX
TYX
LDY $0F
LDA.w LaunchShellSpeeds,y
STA $B6,x
LDA #$0A
STA $14C8,x
LDA #$08
STA $154C,x
LDA #$01
JSL $02ACE5
TXY
PLX
LDA #$80
TRB $0DB9
LDA #$13
STA $1DF9
RTS

GKoopaReturn:
RTS

LaunchKoopaSpeeds:
db $20,$E0
LaunchShellSpeeds:
db $30,$D0

;other koopas = green koopa

Sprite08:
Sprite09:;winged koopas
Sprite0A:
Sprite0B:
Sprite0C:
LDA $1570,x
BEQ +
JMP KillWithStar
+
LDA #$00
JSR LocateContact
BEQ .hurt
LDA $0DB9
BIT #$01
BNE .spinkill
LDA #$08
JSR BounceSquash
LDA $009E,y
SEC
SBC #$08
PHX
TAX
LDA.w .koopanumbers,x
PLX
STA $009E,y
LDA #$04
STA $154C,y
RTS
.spinkill
JSR SpinKillSprite
RTS
.hurt
JSR HurtLuigi
RTS

.koopanumbers
db $04,$04,$05,$05,$07

Sprite0E:;Key Hole
RTS

GoombaWins:
JSR HurtLuigi
RTS

Sprite0F:;Goomba/MechaKoopa/Bob-omb/BuzzyBettle
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA $14C8,y
CMP #$09
BNE GoombaReg
akakakakaka:
JMP GoombaShell
GoombaReg:
LDA #$00
JSR LocateContact
BEQ GoombaWins
LDA $0DB9
BIT #$01
BEQ Labelname23
JMP SpinKillGoomba
Labelname23:
LDA $14C8,y;bonk by jump
CMP #$0A
BNE Labelname24
JMP KickedGoomba;jump if kicked
Labelname24:
LDA #$00
STA $00B6,y
REP #$20
LDA #$FFFC
JSR AddToYpos
;STX $0F
TYX
JMP Labelname22
RTS
GoombaGo:
LDA #$10
STA $1564,Y
STA $154C,Y
LDA $164A,X
STA $164A,Y
STZ $1540,X
PHX
PHY
Labelname22:
TXY
LDX $15E9
;LDA #$00
;STA $00B6,y
KickedGoomba:
LDA #$09
JSR BounceSquash
PHX
TYX 
LDA.B #$FF   ;\Stun Timer For Enemy = FF
STA.W $1540,X;/
TXY
PLX
RTS

SpinKillGoomba:
JSR SpinKillSprite
RTS

GoombaShell:
LDA $0DB9
BIT #$01
BEQ NoSpinGoombaShell
LDA #$00
JSR LocateContact
BNE SpinKillGoomba
NoSpinGoombaShell:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYGoomba
JSR UpdatePosByCarry
LDA $0DB9
BMI +
LDA #$80
TSB $0DB9
LDA #$08
STA $154C,x
+
RTS
NoXYGoomba:
LDA $0DB9
BPL KickGoombaShellLR
JSR UpdatePosByCarry
JSR LetGo
RTS
KickGoombaShellLR:
JSR SubHorzPosLuigi
PHX
TYX
LDY $0F
LDA.w LaunchGoombaShellSpeeds,y
STA $B6,x
LDA #$0A
STA $14C8,x
LDA #$08
STA $154C,x
LDA.B #$02                ;\ 
LDY $9E,X                 ;| 
CPY.B #$11                ;| Get Points if sprite are a Buzzy Bettle: 
BNE GetPoints             ;|
LDA #$01                  ;| $01 = 200 Pts
JSL $02ACE5               ;|  
GetPoints:                ;/ 
TXY
PLX
LDA #$80
TRB $0DB9
LDA #$13
STA $1DF9
RTS

GoombaReturn:
RTS

LaunchGoombaSpeeds:
db $20,$E0
LaunchGoombaShellSpeeds:
db $30,$D0

Sprite10:;Jumping Goomba/Para Goomba
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ JumpingGoombaWin
LDA $0DB9
AND #$01
BNE JumpingGoombaSpinKill
;JSL $01AB99
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$00
JSR BounceSquash
LDA $14C8,Y               ;\
BEQ SpawnGoomba           ;/ ...and spawn Goomba
RTS
JumpingGoombaSpinKill:
JSR SpinKillSprite
RTS
JumpingGoombaWin:
JSR HurtLuigi
RTS
SpawnGoomba:;Spawn Moving coin code XD
LDA #$08        ; \ Sprite status = normal
STA $14C8,Y     ; /
LDA #$0F        ; \ Sprite = Goomba
STA $009E,Y     ; /
PHX
TYX
LDA $E4,X       ; \ Copy X position to goomba
STA $00E4,Y     ;  |
LDA $14E0,X     ;  |
STA $14E0,Y     ; /
LDA $D8,X       ; \ Copy Y position to goomba
STA $00D8,Y     ;  |
LDA $14D4,X     ;  |
STA $14D4,Y     ; /
TXY
PLX
PHX             ; \
TYX             ;  |
JSL $07F7D2     ;  | Clear all sprite tables, and load new values
PLX             ; /
LDA $01         ; \ Set direction
STA $157C,Y     ; /
LDA #$20
STA $154C,Y
RTS

;Buzzy Bettle = Goomba

Sprite12:;??????????
RTS

;Spiny = jumping piranah
;Falling Spiny = jumping piranah
;Fish Horizontal = jumping piranah
;Fish Vertical = jumping piranah
;Surface Jumping Fish = jumping piranah

Sprite1C:;Bullet bill
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ BulletWin
LDA $0DB9
AND #$01
BNE BulletSpinKill
;JSL $01AB99
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
JSR BounceSquash
RTS
BulletSpinKill:
JSR SpinKillSprite
RTS
BulletWin:
JSR HurtLuigi
RTS

;Hopping Flame = jumping piranah

;Lakitu = Bullet Bill

;Magikoopa Magic = jumping piranah

Sprite1F:;MagiKoopa
LDA $1570,y     ;\No Death when Magikoopa is Searching Grounds
CMP #$00        ;/
BNE MagikoopaWin
RTS
MagikoopaWin:
JSR Sprite1C
RTS

Sprite21:;Moving Coin
LDA $0DBF
CMP #$63
BEQ NoGiveCoin
NoGiveCoin:
LDA #$01
STA $1DFC
LDA #$00
STA $14C8,y
LDA #$01
JSL $02ACE5
JSR BlockSparkle
JSL $05B34A			;+1 coin
RTS

Sprite22:
Sprite23:;Net koopas/SwooperBat	;Spin Kill Added <.<
Sprite24:
Sprite25:
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
BNE .return
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ NetKoopaWin
LDA $0DB9
AND #$01
BNE NetKoopaSpinKill
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
JSR BounceSquash
RTS
.return
RTS
NetKoopaSpinKill:
JSR SpinKillSprite
RTS
NetKoopaWin:
JSR HurtLuigi
RTS

;Thwomp + Thwimp = jumping piranah

;Big Boo = jumping piranah

Sprite29:;Koopaling
RTS

;Upside Down Piranha Plant = jumping piranah

;Sumo Brother Light = jumping piranah

;Spike Top = jumping piranah

Sprite2F:;SpringBoard
BEQ NoSpinSpring
NoSpinSpring:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYSpring
JSR UpdatePosByCarry
LDA $0DB9
BMI +
LDA #$80
TSB $0DB9
LDA #$08
STA $154C,x
+
BEQ NoXYSpring
JSR UpdatePosByCarry
RTS
NoXYSpring:
LDA $0DB9
BPL KickSpring
JSR UpdatePosByCarry
JSR LetGo
RTS
KickSpring:
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA #$00
JSR LocateContact
BEQ SpringWin
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
LDA $1570,x
JSR SuperBoostSpeed
LDA #$08 ;\bounce sound
STA $1DFC;/
STZ $00B6,x ;Xspeed is 0 on jumping on a spring
RTS
SpringWin:
JSR SolidSprite
RTS

Sprite30:;DrybonesThrowbones! :D
LDA $1540,y   ;\Check DryBones State
BNE noInteract;/
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ DryBonesWin
;JSL $01AB99
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
LDA $1570,x
JSR BoostSpeed
LDA #$01
JSR BounceSquashNoSound
PHX
TYX
LDA #$07
STA $1DF9
INC.W $1534,x             
LDA.B #$FF                
STA.W $1540,x
TXY
PLX
RTS
noInteract:
RTS
DryBonesWin:
JSR HurtLuigi
RTS

;Bony Bettle = DryBones ThrowBones...Need Check if has spikes
;DryBones = DryBones ThrowBones

;Podoboo = jumping piranah
;Boss FireBall = jumping piranah

Sprite36:;?????????????
RTS

;Boo = jumping piranah
;Eerie = jumping piranah
;Eerie Wave Motion = jumping piranah
;Urchin's = jumping piranah
;Rip Van Fish = jumping piranah

Sprite3E:;P-switch
LDA $0DB9
BIT #$00
BEQ NoSpinPS
NoSpinPS:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYPS
JSR UpdatePosByCarry
LDA $0DB9
BMI +
LDA #$80
TSB $0DB9
LDA #$08
STA $154C,x
+
RTS
NoXYPS:
LDA $0DB9
BPL KickPS
JSR UpdatePosByCarry
JSR LetGo
RTS
KickPS:
JSR SolidSprite
CMP #$01
BNE .end
LDA #$03
STA $14C8,y
LDA #$20
STA $1540,y
LDA #$0B
STA $1DF9
LDA #$0E
STA $1DFB
STZ $AA,x
LDA $151C,y
BNE .SilverP
LDA #$B0
STA $14AD
LDA #$20
STA $1887			; Set earthquake timer
RTS
.SilverP
LDA #$B0
STA $14AE
JSL $02B9BD			; If silver pswitch, set appropriate sprites to coins(Fix)
LDA #$20
STA $1887			; Set earthquake timer
.end
RTS
RTS

Sprite41:;Para Bomb
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ ParaBombWin
LDA $0DB9
AND #$01
BNE ParaBombSpinKill
;JSL $01AB99
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$00
JSR BounceSquash
LDA $14C8,Y               ;\
BEQ SpawnBomb             ;/ ...and spawn Goomba
RTS
ParaBombSpinKill:
JSR SpinKillSprite
RTS
ParaBombWin:
JSR HurtLuigi
RTS
SpawnBomb:
LDA #$08        ; \ Sprite status = normal
STA $14C8,Y     ; /
LDA #$0D        ; \ Sprite = Bomb
STA $009E,Y     ; /
PHX
TYX
LDA $E4,X       ; \ Copy X position to bomb
STA $00E4,Y     ;  |
LDA $14E0,X     ;  |
STA $14E0,Y     ; /
LDA $D8,X       ; \ Copy Y position to bomb
STA $00D8,Y     ;  |
LDA $14D4,X     ;  |
STA $14D4,Y     ; /
TXY
PLX
PHX             ; \
TYX             ;  |
JSL $07F7D2     ;  | Clear all sprite tables, and load new values
PLX             ; /
LDA $01         ; \ Set direction
STA $157C,Y     ; /
LDA #$20
STA $154C,Y
RTS

;Dolphin's = checkerboard platforms

;Torpedo Ted = jumping piranah

;Chuck's = Chargin'Chuck

Sprite47:;Swimming Jumping Fish
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ .fishWins
LDA $0DB9
AND #$01
BNE .fishSpinKill
LDA #$02
JSR BounceSquash
LDA #$00
STA $00B6,y
STA $00AA,y
RTS
.fishSpinKill
JSR SpinKillSprite
RTS
.fishWins
JSR HurtLuigi
.end
RTS

;Diggin Chuck's Rock = jumping piranah

;Growing Pipe = Solid Sprite

Sprite4A:;Goal Point Sphere
LDY #$0C
TYX
JSL EndLevel
LDX $0F65
.end
RTS

;Pipe Lakitu = Bullet Bill

;Exploding Block = Solid Sprite

Sprite4D:
Sprite4E:;Monty Moles
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA $00C2,y
CMP #$02
BCC .end
LDA $14C8,y
CMP #$08
BNE .end
LDA #$00
JSR LocateContact
BEQ .moleWins
LDA $0DB9
AND #$01
BNE .moleSpinKill
LDA #$02
JSR BounceSquash
LDA #$00
STA $00B6,y
STA $00AA,y
RTS
.moleSpinKill
JSR SpinKillSprite
RTS
.moleWins
JSR HurtLuigi
RTS
.end
RTS

Sprite4F:		;Jumping Pirannah
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA $0DB9
AND #$01
BNE CheckContactJP
LloseJP:
JSR HurtLuigi
RTS
CheckContactJP:
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
SEC
SBC #$0004
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$00
JSR LocateContact
PHA
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
CLC
ADC #$0004
SEP #$20
STA $D8,x
XBA
STA $14D4,x
PLA
BEQ LloseJP
JSR BoostSpeed
LDA #$02
STA $1DF9
RTS

;Jumping Piranha Spit Fire = Jumping Piranha

;Ninji = Bullet Bill

Sprite52:;Moving Hole/Ghost House
RTS

Sprite53:;Purple TurnBlock
RTS

Sprite59:			;Turn block bridges
Sprite5A:
;LDA #$08
;TSB $0DB9
LDA #$10
STZ $0D
STA $0C			;platform width
STZ $0F
STA $0E			;platfrorm height
LDA $E4,x
STA $00
LDA $14E0,x		;luigi X
STA $01
LDA $D8,x
CLC
ADC #$10
STA $02			;luigi Y foot
LDA $14D4,x
ADC #$00
STA $03
LDA #$10		;small height
STA $0A
JSR GetHeight
BEQ +
LDA #$20		;big height
STA $0A
+
LDA $02
SEC
SBC $0A
STA $08			;luigi y head
LDA $03
SBC #$00
STA $09
STZ $0B
LDA $00E4,y
STA $04			;Platform X
LDA $14E0,y
STA $05
LDA $00D8,y
STA $06			;platform Y
LDA $14D4,y
STA $07
LDA $009E,y
CMP #$5A
BEQ .horizontal
LDA $00C2,y
AND #$02
BNE .vertical
.horizontal
LDA $151C,y
ASL
CLC
ADC #$10
STA $0C
LDA $04
SEC
SBC $151C,y
STA $04
LDA $05
SBC #$00
STA $05
BRA .docalc

.vertical
LDA $151C,y
ASL
CLC
ADC #$10
STA $0E
LDA $06
SEC
SBC $151C,y
STA $06
LDA $07
SBC #$00
STA $07
.docalc
REP #$20
LDA $02
SEC
SBC #$0010
CMP $06
BCS .nottop
SEP #$20
LDA $AA,x
BMI +
REP #$20
LDA $06
SEC
SBC #$000F
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$40
STA $AA,x
LDA #$04
ORA $1588,x
STA $1588,x
;LDA #$08
;TSB $0DB9
+
RTS

.nottop
LDA $0F
CLC
ADC $06
DEC
DEC
CMP $08
BCS .notbottom
LDA $06
CLC
ADC $0E
CLC
ADC $0A
SEC
SBC #$0010
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$18
STA $AA,x
LDA #$01
STA $1DF9
LDA #$08
ORA $1588,x
STA $1588,x
RTS

.notbottom
LDA $00
CMP $04
BCS .right
LDA $04
SEC
SBC #$000F
SEP #$20
STZ $B6,x
LDA #$01
ORA $1588,x
STA $1588,x
RTS

.right
LDA $04
CLC
ADC $0C
DEC
SEP #$20
STA $E4,x
XBA
STA $14E0,x
STZ $B6,x
LDA #$02
ORA $1588,x
STA $1588,x
RTS

Sprite5C:
RTS

Sprite5D:		;Sprite 5D - Orange sinking platform
JSR SimplePlatform
BCC .end
PHX
LDX #$03
LDA $0DB9
BIT #$18
BNE +
DEX
+
STX $00
TYX
LDA $AA,x
CMP $00
BPL +
CLC
ADC #$02
STA $AA,x
+
PLX
.end
SEP #$20
RTS

Sprite5F:		; Brown platform on a chain
JSR SimplePlatform
BCC .end

LDA #$03
STA $1602,y
LDA $13
LSR
BCS .end
; copypasted brown platform acceleration code
PHX
TYX
LDA $151C,x
CLC
ADC #$80
LDA $1528,x
ADC #$00
AND #$01
TAY
LDA $1504,x
CMP.w DATA_01C9D8,y
BEQ +
CLC
ADC.w DATA_01C9D6,y
STA $1504,x
+
TXY
PLX

.end
RTS

DATA_01C9D6:              db $01,$FF
DATA_01C9D8:              db $40,$C0

Sprite55:		; Vertical/horizontal checkerboard platforms
Sprite57:
Sprite62:		; Line guided brown platform
SpriteA3:		; Sprite A3 - Grey rotating platform
SimplePlatform:
LDA $AA,x		; if moving up return
BMI .end

LDA $0B			; mutate clipping info into ypos for collision top at $05
STA $06

LDA $14D4,x		; compare ypos + #$0D to platform - must be within 5 pixel window
XBA
LDA $D8,x
REP #$20
CLC
ADC #$000D
SEC
SBC $05
CMP #$0005
BCS .end

LDA $05			; lock luigi ypos to platform
SEC
SBC #$000D
SEP #$20
STA $D8,x
XBA
STA $14D4,x

LDA #$08		; set yspeed
STA $AA,x

LDA $1588,x		; mark touching ground
ORA #$04
STA $1588,x

STY $0F60		; mark this sprite index as being ridden (for position updates)

SEC
RTS

.end
SEP #$20
CLC
RTS

;Flat Green Switch = Solid Sprite

Sprite61:;Floating Skulls
PHX
TYX
LDA.W $18BC               
STA $B6,X 
LDA.B #$0C                
STA.W $18BC
TXY
PLX
JSR SimplePlatform
JSR SolidSprite
RTS

Sprite63:;Checker/Brown Plataform
JSR Sprite62
BCC +
LDA #$00
STA $1626,y
STA $1540,y
+
RTS

Sprite64:;Rope Mechanism
RTS

;ChainSaw's = Jumping Piranha

;Grinder's = Jumping Piranha

;Fuzz Ball = Jumping Piranha

Sprite69:;??????????????
RTS

Sprite6A:;Coin Game Cloud
RTS

Sprite6B:;Spring Board /Left Wall
RTS

Sprite6C:;Spring Board /Right Wall
RTS

Sprite6D:		;invisible solid block
SolidSprite:
LDA $14D4,y
STA $03
LDA $00D8,y
STA $02			; $02 = Block's top
STZ $04
STZ $05
JSR GetHeight
BEQ +
LDA #$0B
STA $04			; $04 = Luigi's height - #$10
+
LDA $14D4,x
STA $01
XBA
LDA $D8,x
STA $00			;$00 = Luigi's y-position
REP #$20
SEC
SBC $04
STA $04			;$04 = Luigi's top (b/c being big doesn't change the y-position)
LDA $00
CLC
ADC #$0008
CMP $02
BCS .nottop
SEP #$20		; We're standing on the block!
LDA $AA,x
BMI .endthing
REP #$20
LDA $02
SEC
SBC #$000F
SEP #$20
STA $D8,x
XBA
STA $14D4,x
STZ $AA,x
LDA #$04
ORA $1588,x
STA $1588,x
LDA #$01
RTS

.nottop
LDA $04
SEC
SBC #$000A
CMP $02
BCC .notbottom
SEP #$20		; We're hitting our head on the block!
LDA $AA,x
BPL .endthing
REP #$20
LDA $00
SEC
SBC $04
CLC
ADC $02
CLC
ADC #$000F
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$FF
STA $AA,x
LDA #$01
STA $1DF9
LDA #$02
RTS

.endthing
LDA #$00		; We hit nothing :(
RTS

.notbottom
SEP #$20
LDA $14E0,y
STA $03
LDA $00E4,y
STA $02
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
CMP $02
BCS .onright
LDA $02
SEC
SBC #$000F
SEP #$20
STA $E4,x
XBA
STA $14E0,x
STZ $B6,x
LDA #$03
RTS
.onright
LDA $02
CLC
ADC #$000F
SEP #$20
STA $E4,x
XBA
STA $14E0,x
STZ $B6,x
LDA #$04
RTS

Sprite6E:;Dino Rhino
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ DinoRhinoWin
LDA $0DB9
AND #$01
BNE DinoRhinoSpinKill
;JSL $01AB99
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$00
JSR BounceSquash
LDA $14C8,Y               ;\
BEQ SpawnDinoTorch        ;/ ...and spawn DinoTorch
RTS
DinoRhinoSpinKill:
JSR SpinKillSprite
RTS
DinoRhinoWin:
JSR HurtLuigi
RTS
SpawnDinoTorch:
LDA #$08        ; \ Sprite status = normal
STA $14C8,Y     ; /
LDA #$6F        ; \ Sprite = Dino Torch
STA $009E,Y     ; /
PHX
TYX
LDA $E4,X       ; \ Copy X position to bomb
STA $00E4,Y     ;  |
LDA $14E0,X     ;  |
STA $14E0,Y     ; /
LDA $D8,X       ; \ Copy Y position to bomb
STA $00D8,Y     ;  |
LDA $14D4,X     ;  |
STA $14D4,Y     ; /
TXY
PLX
PHX             ; \
TYX             ;  |
JSL $07F7D2     ;  | Clear all sprite tables, and load new values
PLX             ; /
LDA $01         ; \ Set direction
STA $157C,Y     ; /
LDA #$20
STA $154C,Y
RTS

;Dino Torch = koopa no shell

Sprite70:; Pokey
LDX #$00
LDA $00C2,y
LSR
BCC +
INX
+
LSR
BCC +
INX
+
LSR
BCC +
INX
+
LSR
BCC +
INX
+
LSR
BCC +
INX
+
TXA
ASL #4
EOR #$FF
CLC
ADC #$51
STA $00; $00 = Distance between pokey top and pokey ypos
STZ $01
LDA $14D4,y
XBA
LDA $00D8,y
REP #$20
PHA
CLC
ADC $00
SEP #$20
STA $00D8,y
XBA
STA $14D4,y
LDX $0F65
JSR Sprite4F; Interact with as jumping pirannah
PLA
STA $00D8,y
PLA
STA $14D4,y
RTS

Sprite71:;Swooper koopas
Sprite72:
GenericMomentumKill:
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ .fishWins
LDA $0DB9
AND #$01
BNE .fishSpinKill
LDA #$02
JSR BounceSquash
LDA #$00
STA $00AA,y
RTS
.fishSpinKill
JSR SpinKillSprite
RTS
.fishWins
JSR HurtLuigi
.end
RTS

Sprite73:;Super koopas
LDA $1656,y
CMP #$10
BEQ GenericMomentumKill
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact
BEQ .fishWins
LDA $0DB9
AND #$01
BNE .fishSpinKill
LDA #$01
JSR BounceSquash
PHX
PHY
TYX
JSL $02EAF2
;JSL $02A9E4
;BMI +
PLY
LDA #$02
STA $009E,y
PHY
TYX
JSL $07F7D2
LDA #$08
STA $154C,x
+
PLY
PLX
RTS
.fishSpinKill
JSR SpinKillSprite
RTS
.fishWins
JSR HurtLuigi
.end
RTS

Sprite74:;Mushroom
LDA #$00
STA $14C8,y
LDA #$0A
STA $1DF9
LDA #$04
JSR GetPointsFromY
LDA $0DB9
AND #$18
BNE MushReturn
LDA #$08
TSB $0DB9
LDA #$30
STA $1540,x
RTS
MushReturn:
LDA #$0B
STA $1DFC
LDA #$01
STA $0DC2		;Item Box Item = Mushroom
RTS

Sprite75:;Flower
LDA #$00
STA $14C8,y
LDA #$0A
STA $1DF9
LDA #$04
JSR GetPointsFromY
LDA $0DB9
AND #$18;if already have cape, don't play animation
CMP #$10
BNE +
LDA #$04			;Item Number
STA $0DC2		;Item Box Item = Feather
LDA #$0B
STA $1DFC
LDA $0DB9
AND #$18
CMP #$18
BEQ .alreadyhave
LDA #$18
TSB $0DB9
LDA #$30
STA $1540,x
RTS
+
LDA $0DB9
AND #$18
CMP #$18
BEQ .alreadyhave
LDA #$18
TSB $0DB9
LDA #$30
STA $1540,x
RTS
.alreadyhave
LDA #$0B
STA $1DFC
LDA #$02			;
STA $0DC2		;Item Box Item = Fire Flower
RTS

Sprite76:;star
LDA #$00
STA $14C8,y
LDA #$04
JSR GetPointsFromY
LDA #$60
STA $1570,x
LDA #$0A
STA $1DF9
LDA #$0D
STA $1DFB
RTS

Sprite77:;feather
LDA #$00
STA $14C8,y
LDA #$04
JSR GetPointsFromY
LDA $0DB9
AND #$18
CMP #$18
BEQ .alreadyhaveflower
LDA $0DB9
AND #$18;if already have cape, don't play animation
CMP #$10
BNE +
LDA #$04			;Item Number
STA $0DC2		;Item Box Item = Feather
LDA #$0A
STA $1DF9
LDA #$0B
STA $1DFC
RTS
+
LDA #$0D
STA $1DF9
LDA $0DB9
AND #$E7
ORA #$10
STA $0DB9
LDA #$18
STA $151C,x
PHY
LDY #$03
-
LDA $17C0,y
BEQ +
DEY
BPL -
DEC $1863
BPL ++
LDA #$03
STA $1863
++
LDY $1863
+
LDA #$81
STA $17C0,y
LDA #$1B
STA $17CC,y
LDA $D8,x
CLC
ADC #$08
STA $17C4,y
LDA $E4,x
STA $17C8,y
LDA #$30
STA $1540,x
PLY
RTS
.alreadyhaveflower
LDA #$0B
STA $1DFC
LDA #$02			;
STA $0DC2		;Item Box Item = Fire Flower
LDA #$00
STA $14C8,y
LDA $0DB9
AND #$18;if already have cape, don't play animation
CMP #$10
BNE +
LDA #$04			;Item Number
STA $0DC2		;Item Box Item = Feather
LDA #$0B
STA $1DFC
RTS
+
LDA #$0D
STA $1DF9
LDA $0DB9
AND #$E7
ORA #$10
STA $0DB9
LDA #$18
STA $151C,x
PHY
LDY #$03
-
LDA $17C0,y
BEQ +
DEY
BPL -
DEC $1863
BPL ++
LDA #$03
STA $1863
++
LDY $1863
+
LDA #$81
STA $17C0,y
LDA #$1B
STA $17CC,y
LDA $D8,x
CLC
ADC #$08
STA $17C4,y
LDA $E4,x
STA $17C8,y
LDA #$30
STA $1540,x
PLY
RTS

Sprite78:;1-up
LDA #$00
STA $14C8,y
OneUpRex:
LDA #$10
PHX
TYX
JSL $02ACEF
TXY
PLX
RTS

Sprite79:;growing vine
RTS

Sprite7A:;Fire Work
RTS

Sprite7B:;goal
RTS

Sprite7C:;Secret Goal
RTS

Sprite7D:;P-Ballon
RTS

Sprite7E:;Flying Red Coin
LDA $0DBF
CMP #$63
BEQ NoGiveRedCoin
NoGiveRedCoin:
LDA #$01
STA $1DFC
LDA #$00
STA $14C8,y
LDA #$03
JSL $02ACE5
JSL $05B34A;\
JSL $05B34A;|
JSL $05B34A;|+5 coin
JSL $05B34A;|
JSL $05B34A;/
JSL $00BEB0
JSR BlockSparkle
RTS

Sprite80:;Key
LDA $0DB9
BIT #$00
BEQ NoSpinKey
NoSpinKey:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYKey
JSR UpdatePosByCarry
LDA $0DB9
BMI +
LDA #$80
TSB $0DB9
LDA #$08
STA $154C,x
+
RTS
NoXYKey:
LDA $0DB9
BPL KickKey
JSR LetGo
RTS
KickKey:
JSR SolidSprite
RTS

Sprite81:;changing item
SEP #$10
LDA $187B,y               ; \ Determine which power-up to act like
LSR                       ;  |
LSR                       ;  |
LSR                       ;  |
LSR                       ;  |
LSR                       ;  |
LSR                       ;  |
AND #$03                  ;  |
ASL  ;  |
TAX                       ;  |
JMP (ChangingItem,x)  ; /

ChangingItem:
dw Sprite74
dw Sprite75
dw Sprite77
dw Sprite76


Sprite82:		;bonus game thing
LDA $AA,x
BPL .end
LDA $0DB9
AND #$02
ASL #3
CLC
ADC #$0C		;ducking:20   standing:10
CLC
ADC $00D8,y
STA $00
LDA $14D4,y
ADC #$00
STA $01
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
SEC
SBC $00
CMP #$0004
SEP #$20
BCS .end
LDA #$10
STA $AA,x
TYX
PHK
PEA.w .return-1
PEA $EA1F
JML $81DE77
.return
TXY
.end
RTS

Sprite83:;flying question block
JSR SimplePlatform
JSR SolidSprite
PHA
LDA $00C2,y
BNE .pullend
PLA
BEQ .end
CMP #$03
BCS .end
CMP #$01
BEQ .top
LDA #$10
STA $1558,y
RTS
.top
LDA $00AA,y
BMI +
ASL
BRA ++
+
LDA #$00
++
STA $AA,x
LDA $E4,x
STA $00
LDA $14E0,x
STA $01
LDA $1528,y
BMI +
LDA #$00
BRA ++
+
LDA #$FF
++
XBA
LDA $1528,y
REP #$20
CLC
ADC $00
SEP #$20
STA $E4,x
XBA
STA $14E0,x
.end
RTS
.pullend
PLA
RTS

Sprite85:;???????????
RTS

Sprite86:;Wiggler
RTS

Sprite87:;Lakitu Cloud
RTS

Sprite88:;????????????
RTS

Sprite89:;Layer 3 Smash
RTS

Sprite8A:;Bird Yoshi House
RTS

Sprite8B:;Puf Smoke Yoshi House
RTS

Sprite8C:;Fireplace smoke/side exit enabled
RTS

Sprite8D:;Ghost House Exit Sing and Door
RTS

Sprite8E:;Warp hole
LDA $E4,x
CLC
ADC #$30
STA $E4,x
LDA $14E0,x
ADC #$00
STA $14E0,x
RTS

Sprite8F:;Scale Plataforms
RTS

Sprite91:;Chargin' chuck
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact;\if the chuck wins
BEQ ChuckWins;/hurt player
JSR BoostSpeed
LDA #$02;\bounce sound
STA $1DF9;/
LDA $00C2,y;\if stunned
CMP #$03; |
BEQ ChuckBounce;/don't hurt
LDA $1528,y;\inc hitpoints
INC; |
STA $1528,y;/
CMP #$03;\if three, kill
BEQ KillChuck;/

LDA #$28                ;\ Play sound effect ;From chuck dissasembly
STA $1DFC               ;/
LDA #$03
STA $00C2,y
STA $1540,y
LDA #$00
STA $1570,y
PHY
JSR ADDR_02D4FA
LDA ChuckBounceXsp,Y
PLY
STA $00B6,x
RTS

KillChuck:
LDA #$02
STA $14C8,y
LDA #$13
STA $1DF9
;
LDA #$03
JSL $02ACE5
ChuckBounce:
RTS

ChuckWins:
JSR HurtLuigi
RTS

ChuckBounceXsp:
db $20,$E0

ADDR_02D4FA:
LDA $E4,x
SEC
SBC $00E4,y
STA $0F                   ;return sprite's xpos reletive to mario
LDA $14E0,x
SBC $14E0,y
PHP
LDY #$00
PLP
BPL Return02D50B
INY                       ;return y as 1 if player on left of enemy
Return02D50B:
RTS

;Volcano Lotus = Jumping Piranha
;Sumo Brother = Jumping Piranha

;Amazing Flying Hammer Brother = Bullet Bill

Sprite9C:;Amazing Flying Hammer Brother Blocks
JSR SimplePlatform
JSR SolidSprite
CMP #$02
BNE .end
LDA #$10
STA $1558,y
.end
RTS

Sprite9D:;Bubble With a Goomba/bomb/Fish/Mushroom
PHX
TYX
LDA.W $1534,X
CMP.B #$07
BCC noExplode
LDA.B #$06                
STA.W $1534,X
noExplode:
TXY
PLX
STZ $B6,x;Stop Movement Xspeed
STZ $AA,x;Stop Movement Yspeed
RTS

Sprite9F:;Banzai bill
LDA $1570,x
BEQ $03
JMP KillWithStar
REP #$20
LDA #$FFF0
JSR AddToYpos
LDA #$00
JSR LocateContact
PHA
REP #$20
LDA #$0010
JSR AddToYpos
PLA
BEQ BanzaiWin
LDA $0DB9
AND #$01
BNE BanzaiSpinKill
;JSL $01AB99
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
JSR BounceSquash
RTS
BanzaiSpinKill:
JSR SpinKillSprite
RTS
BanzaiWin:
JSR HurtLuigi
RTS

SpriteA0:;Activate Bowser Scene
RTS

SpriteAB:;Rex
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA $1FE2,y
ORA $1558,y
BNE RexEnd
LDA #$00
JSR LocateContact
BEQ RexWins
LDA $0DB9
AND #$01
BNE RexSpinKill
PHX
TYX
INC $C2,x
PLX
LDA $00C2,y
CMP #$02
BNE SmushRex
LDA #$08
JSR BounceSquash
LDA #$20
STA $1558,y
RexEnd:
RTS
SmushRex:
LDA #$0C                ; \ Time to show semi-squashed Rex = $0C
STA $1FE2,y             ; /
LDA #$00
STA $1662,y  ; Change clipping area for squashed Rex
LDA #$08
JSR BounceSquash
RTS
RexSpinKill:
JSR SpinKillSprite
JSR BoostSpeed
RTS
RexWins:
JSR HurtLuigi
RTS

SpriteAC:;Wooden Spike Up
RTS

SpriteAD:;Wooden Spike Down
RTS

SpriteB9:;Message Box
JSR SolidSprite
CMP #$02
BNE .end
LDA #$10
STA $1558,y
.end
RTS

SpriteBA:;Timed Lift 4/1 Seconds
JSR SimplePlatform
BCC .end
PHX
LDX #$03
LDA $0DB9
BIT #$18
BNE +
DEX
+
PHX
TYX
LDA.B #$10   ;\ set sprite state and trigger movement
STA $B6,X    ;|
STA $C2,X    ;/
TXY
PLX
+
PLX
.end
SEP #$20
RTS

SpriteBB:;Grey Moving Castle Block
JSR SimplePlatform
JSR SolidSprite
RTS

SpriteBC:;Bowser Statue
RTS

SpriteBE:;?????????????
RTS

SpriteBF:;MegaMole
JSR SimplePlatform
RTS

SpriteC1:;Grey Flying Turn Blocks
JSR SimplePlatform
JSR SolidSprite
RTS

SpriteC4:;Gray Platform that fall's
JSR SimplePlatform
BCC .end
PHX
LDX #$03
LDA $0DB9
BIT #$18
BNE +
DEX
+
PHX
TYX
LDA $AA,X    ;\ if sprite already moving,
BNE .moving  ;/ return
LDA.B #$03   ;\ else, set initial speed
STA $AA,X
LDA.B #$18   ;\ set time before accelerating starts
STA.W $1540,X;/
.moving
TXY
PLX
+
PLX
.end
SEP #$20
RTS

;Big Boo Boss = MadeNone

SpriteC7:;Invisible mushroom
TYX
PHX
JSL GenMushroom
PLY
RTS

pushpc
org $03E05C; Freespace - just allows this call to be made from our bank
GenMushroom:
JSR $C318
RTL
pullpc

SpriteC9:;Bullet Bill Shoter
RTS

ExtSprSize:
	db $00,$08,$04,$08,$00,$08,$00
db $00,$00,$08,$04,$04,$04,$00,$00
db $00,$00,$00

ExtSprites:
LDX #$07
.loopstart
LDA $170B,x
BEQ .continue
DEC
TAY
LDA.w ExtSprSize,y
BEQ .continue
STA $0F
CLC
ADC $171F,x
STA $00
LDA $1733,x
ADC #$00
STA $01
LDA $0F
CLC
ADC $1715,x
STA $02
LDA $1729,x
ADC #$00
STA $03
PHX
LDX $0F65
LDA $E4,x
STA $04
LDA $14E0,x
STA $05
LDA $0DB9
AND #$02
EOR #$02
ASL #3
CLC
ADC #$10			;10: Ducking - 20: Standing
STA $06
STZ $07
LDA $14D4,x
XBA
LDA $D8,x
PLX
REP #$20
CLC
ADC #$0010
SEC
SBC $06
STA $08
LDA $00
SEC
SBC $04
CMP #$0010
SEP #$20
BCS .continue
REP #$20
LDA $02
SEC
SBC $08
CMP $06
SEP #$20
BCS .continue
LDA $170B,x
CMP #$0A
BEQ .coinprocess
JSR HurtLuigi
BRA .endloop
.coinprocess
				;TODO - interact with coin game coin!
BRA .endloop
.continue
DEX
BMI .endloop
JMP .loopstart
.endloop
LDX $0F65
RTS

ClusterSprites:
LDY #$13
.loopstart
LDA $1892,y
BEQ .continue
TAX
LDA.w .inttype-1,x
BEQ .continue

DEC
BNE .typetwo
JSR TypeOne
BRA .continue

.typetwo				;1up, maybe more?
DEC
BNE .typethree
JSR TypeTwo
BRA .continue

.typethree
.continue
DEY
BPL .loopstart
LDX $0F65
RTS

.inttype
db $02,$00,$01,$01,$00,$FF,$01,$FF

TypeOne:
LDA $1E16,y				;Boo ceiling, disappearing boos
STA $04
LDA $1E3E,y
STA $0A
LDA $1E02,y
STA $05
LDA $1E2A,y
STA $0B
LDA #$0A
STA $06
STA $07
TYX
JSR ClipWithMe
TXY
BCC .end
LDA $1892,y
CMP #$07
BNE +
LDA $190A			;2 - conditional kill - $190A
SEC
SBC #$40
CMP #$A0
BCS .end
JSR HurtLuigi
RTS
+
CMP #$03
BNE +
LDA $0F86,y			;3 - conditional kill - $0F86,y
BEQ .end
+
JSR HurtLuigi
.end
RTS

TypeTwo:
LDX $0F65
LDA $E4,x
SEC
SBC $1E16,y
CLC
ADC #$0C
CMP #$1E
BCS .end
LDA #$20
STA $00
LDA $0DB9
BIT #$02
BNE +
LDA #$30
STA $00
+
LDA $D8,x
SEC
SBC $1E02,y
CLC
ADC #$20
CMP $00
BCS .end
LDA #$00			;4 - 1up
STA $1892,y
LDA #$10
LDX $0F65
PHY
JSL $82ACEF
PLY
DEC $1920
BNE .end
LDA #$58
STA $14AB
.end
RTS
