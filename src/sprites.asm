Sprites:
LDX #$0B;Load # of sprites
INTRLOOP:;Loopstart above get-self-clipping so moar scratch ram can be used
CPX $0F65
BEQ NEXTSPR
LDA $14C8,x
CMP #$08
BCC NEXTSPR
LDA $154C,x
BNE NEXTSPR
JSL $83B69F;get clipping for client sprite
LDA $9E,x
CMP #$5F
BNE +
JSR GetBrownPlatClip
BRA ++
+
CMP #$59
BNE +
-
JSR GetTurnBrdgClip
BRA ++
+
CMP #$5A
BEQ -
CMP #$62
BNE +
-
JSR MovingPlatClip
+
CMP #$63
BEQ -
CMP #$A3
BNE +
JSR RotPlatClip
BRA ++
+
++
JSR ClipWithMe
BCC NEXTSPR;if no contact, continue loop
LDA $0DB9
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
TXY;client sprite index to Y
JSR SPRITE_INTERACT;interact
TYX;client back to X
NEXTSPR:
DEX;next sprite
BPL INTRLOOP;If done, end
INTREND:
LDX $0F65
RTS

ClipWithMe:;Uses: $00,$01,$02,$03,$08,$09
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
STA $09  ; $09 = (Sprite Y position + displacement) High byte
LDA.w .negtentwenty,y                  ; $03 = Clipping height
STA $03
JSL $83B72B
PLX
RTS

.tentwenty
db $00,$10

.negtentwenty
db $10,$20

GetBrownPlatClip:
LDA $14B8
SEC
SBC #$18
STA $04
LDA $14B9
SBC #$00
STA $0A
LDA #$40
STA $06
LDA $14BA
SEC
SBC #$0C
STA $05
LDA $14BB
SBC #$00
STA $0B
LDA #$13
STA $07
RTS

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

RotPlatClip:;here's hoping this works!
LDA $151C,X
STA $01
LDA $1602,X
STA $00                   ; $00 = 1602-151C
PHX
REP #$30                  ; Index (16 bit) Accum (16 bit)
LDA $00
CLC
ADC #$0080
AND #$01FF
STA $02                   ; $02 = $00 + #$80 % #$0200
LDA $00
AND #$00FF
ASL
TAX
LDA $07F7DB,X
STA $04
LDA $02
AND #$00FF
ASL
TAX
LDA $07F7DB,X
STA $06
SEP #$30                  ; Index (8 bit) Accum (8 bit)
PLX               ; X = Sprite index
LDA $04
STA $4202               ; Multiplicand A
LDA $187B,X
LDY $05
BNE +
STA $4203               ; Multplier B
NOP #8         ; wait for multiplication to complete
ASL $4216               ; Product/Remainder Result (Low Byte)
LDA $4217               ; Product/Remainder Result (High Byte)
ADC #$00
+
LSR $01
BCC +
EOR #$FF
INC A
STA $04
+
LDA $06
STA $4202               ; Multiplicand A
LDA $187B,X
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
LDA $E4,X
PHA
LDA $14E0,X
PHA
LDA $D8,X
PHA
LDA $14D4,X
PHA
LDY $0F86,X
STZ $00
LDA $04
BPL +
DEC $00
+
CLC
ADC $E4,X
STA $E4,X
PHP
PHA
SEC
SBC $1534,X
STA $1528,X
PLA
STA $1534,X
PLP
LDA $14E0,X
ADC $00
STA $14E0,X
STZ $01
LDA $06
BPL +
DEC $01
+
CLC
ADC $D8,X
STA $D8,X
LDA $14D4,X
ADC $01
STA $14D4,X
JSR MovingPlatClip
PLA
STA $14D4,x
PLA
STA $D8,x
PLA
STA $14E0,x
PLA
STA $E4,x
RTS

DATA_01E6FD:
db $00,$02,$00

Jump:
JSR SolidSprite
BPL .SpringJump
LDA $0F6A
BIT #$04
BNE .end
LDA $0DB9
BMI .SpringJump
LDA #$01
TSB $0DB9
LDA #$22
TRB $0DB9
LDA #$04
STA $1DFC
INX
BRA +
.SpringJump
LDA #$09
TRB $0F6A
LDA #$08                ; \ Play sound effect
STA $1DFC 
+
LDA $00D2BD,x
LDX $0F65
STA $AA,x
INC $0F64
.end
LDX $0F65
RTS

JumpNoSquash:;JUMP NO MATANDO SPRITES
JSR SolidSprite
BPL .normaljump
LDA $0F6A
BIT #$04
BNE .end
LDA $0DB9
BMI .normaljump
LDA #$01
TSB $0DB9
LDA #$22
TRB $0DB9
LDA #$04
STA $1DFC
INX
BRA +
.normaljump
LDA #$09
TRB $0F6A
LDA #$00                ; \ Play sound effect
STA $1DFC 
+
LDA $00D2BD,x
LDX $0F65
STA $AA,x
INC $0F64
.end
LDX $0F65
RTS

BounceSolid:;Bounce!
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
LDA #$00
JSR LocateContact
BEQ BounceSolidWin
LDA $0DB9
AND #$01
BNE BounceSolidSpinKill
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
JSR Jump
RTS
BounceSolidSpinKill:
JSR SolidSprite
RTS
BounceSolidWin:
JSR SolidSprite
RTS

BounceNoSquash:;Bounce sin matar sprites!
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
LDA #$00
JSR LocateContact
BEQ BounceNoSquashWin
LDA $0DB9
AND #$01
BNE BounceNoSquashSpinKill
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
JSR JumpNoSquash
RTS
BounceNoSquashSpinKill:
JSR SolidSprite
RTS
BounceNoSquashWin:
JSR SolidSprite
RTS

BounceNoSolid:;Bounce!
LDA $0F6A
AND #$10
LDA $0F6A
AND #$10
LSR #4
AND #$01
CMP $1632,y
LDA $1570,x
LDA #$00
JSR LocateContact
BEQ BounceNoSolidWin
LDA $0DB9
AND #$01
BNE BounceNoSolidSpinKill
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
JSR SuperBoostSpeed
RTS
BounceNoSolidSpinKill:
RTS
BounceNoSolidWin:
RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                   ;;
;; SPRITE_INTERACT                                                                   ;;
;;                                                                                   ;;
;; Oh, lovely, I get to code interaction with EVERY SINGLE ****ING SPRITE IN THE GAME;;
;; :(                                                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_INTERACT:
LDA $009E,y;\client sprite #
REP #$30; |set 16 bit A
AND #$00FF; |clear high byte
ASL; |double
TAX
LDA.w Ptr,x
STA $00; |store to scratch
SEP #$30; |8 bit A
LDX $0F65
JMP ($0000);/Jump to correct interaction routine

Ptr:
DW Sprite00
DW Sprite00
DW Sprite00
DW Sprite00
DW Sprite04
DW Sprite04
DW Sprite04
DW Sprite04
DW Sprite08
DW Sprite09
DW Sprite0A
DW Sprite0B
DW Sprite0C
DW Sprite0D
DW Sprite0E
DW Sprite0F
DW Sprite10
DW Sprite11
DW Sprite12
DW Sprite41
DW Sprite41
DW Sprite4F
DW Sprite4F
DW Sprite47
DW Sprite47
DW Sprite19
DW Sprite4F
DW Sprite1B
DW Sprite1C
DW Sprite41
DW Sprite1E
DW Sprite1F
DW Sprite4F
DW Sprite21
DW Sprite22
DW Sprite23
DW Sprite24
DW Sprite25
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite29
DW Sprite2A
DW Sprite2B
DW Sprite2C
DW Sprite2D
DW Sprite4F
DW Sprite2F
DW Sprite30
DW Sprite31
DW Sprite32
DW Sprite4F
DW Sprite4F
DW Sprite35
DW Sprite36
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite3E
DW Sprite3F
DW Sprite40
DW Sprite41
DW Sprite42
DW Sprite43
DW Sprite44
DW Sprite45
DW Sprite91
DW Sprite47
DW Sprite4F
DW Sprite49
DW Sprite4A
DW Sprite4B
DW Sprite4C
DW Sprite4D
DW Sprite4E
DW Sprite4F
DW Sprite4F
DW Sprite51
DW Sprite52
DW Sprite53
DW Sprite54
DW Sprite55
DW Sprite56
DW Sprite57
DW Sprite58
DW Sprite59
DW Sprite5A
DW Sprite5B
DW Sprite5C
DW Sprite5D
DW Sprite5E
DW Sprite5F
DW Sprite60
DW Sprite61
DW Sprite62
DW Sprite63
DW Sprite64
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite69
DW Sprite6A
DW Sprite6B
DW Sprite6C
DW Sprite6D
DW Sprite6E
DW Sprite6F
DW Sprite70
DW Sprite71
DW Sprite72
DW Sprite73
DW Sprite74
DW Sprite75
DW Sprite76
DW Sprite77
DW Sprite78
DW Sprite79
DW Sprite7A
DW Sprite7B
DW Sprite7C
DW Sprite7D
DW Sprite7E
DW Sprite78
DW Sprite80
DW Sprite81
DW Sprite82
DW Sprite83
DW Sprite84
DW Sprite85
DW Sprite86
DW Sprite87
DW Sprite88
DW Sprite89
DW Sprite8A
DW Sprite8B
DW Sprite8C
DW Sprite8D
DW Sprite8E
DW Sprite8F
DW Sprite90
DW Sprite91
DW Sprite91
DW Sprite91
DW Sprite91
DW Sprite91
DW Sprite91
DW Sprite91
DW Sprite91
DW Sprite4F
DW Sprite4F
DW Sprite9B
DW Sprite9C
DW Sprite9D
DW Sprite4F
DW Sprite9F
DW SpriteA0
DW SpriteA1
DW SpriteA2
DW SpriteA3
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW SpriteAB
DW SpriteAC
DW SpriteAD
DW SpriteAE
DW SpriteAF
DW SpriteB0
DW SpriteB1
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW Sprite4F
DW SpriteB7
DW SpriteB8
DW SpriteB9
DW SpriteBA
DW SpriteBB
DW SpriteBC
DW Sprite00
DW Sprite23
DW SpriteBF
DW SpriteC0
DW SpriteC1
DW Sprite4F
DW Sprite4F
DW SpriteC4
DW SpriteC5
DW SpriteC6
DW SpriteC7
DW SpriteC8
DW SpriteC9
DW SpriteCA



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
JSL $02A9DE;\Get sprite slot to y
BPL GKoopaGo;/if none, return
JMP Labelname7
RTS
GKoopaGo:
LDA #$08                ; \ Sprite status = Normal
STA $14C8,Y             ; /
PHX
LDA $9E,X       ; \ Store sprite number for shelless koopa
TAX                     ;  |
LDA $01961C,X ;  |
STA $009E,Y     ; /
TYX                     ; \ Reset sprite tables
JSL $07F7D2    ;  |
PLX                ; /
LDA $E4,X       ; \ Shelless Koopa position = Koopa position
STA $00E4,Y     ;  |
LDA $14E0,X     ;  |
STA $14E0,Y     ;  |
LDA $D8,X       ;  |
STA $00D8,Y     ;  |
LDA $14D4,X     ;  |
STA $14D4,Y     ; /
LDA #$00                ; \ Direction = 0
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

Sprite0D:;Bob-omb
JSR Sprite0F
RTS

Sprite0E:;Key Hole
RTS

GoombaWins:
JSR HurtLuigi
RTS

Sprite0F:;Goomba
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
JMP KickedShellGoomba;jump if kicked
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
KickedShellGoomba:
LDA #$09
JSR BounceSquash
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

Sprite10:;Jumping Goomba
JSR Sprite91
RTS

BuzzyWins:
JSR HurtLuigi
RTS

Sprite11:;Buzzy Beetle
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA $14C8,y
CMP #$09
BNE BuzzyReg
akakakaka:
JMP BuzzyShell
BuzzyReg:
LDA #$00
JSR LocateContact
BEQ BuzzyWins
LDA $0DB9
BIT #$01
BEQ Labelname20
JMP SpinKillBuzzy
Labelname20:
LDA $14C8,y;bonk by jump
CMP #$0A
BNE Labelname21
JMP KickedShellBuzzy;jump if kicked
Labelname21:
LDA #$00
STA $00B6,y
REP #$20
LDA #$FFFC
JSR AddToYpos
;STX $0F
TYX
JMP Labelname19
RTS
BuzzyGo:
LDA #$10
STA $1564,Y
STA $154C,Y
LDA $164A,X
STA $164A,Y
STZ $1540,X
PHX
PHY
Labelname19:
TXY
LDX $15E9
;LDA #$00
;STA $00B6,y
KickedShellBuzzy:
LDA #$09
JSR BounceSquash
RTS

SpinKillBuzzy:
JSR SpinKillSprite
RTS

BuzzyShell:
LDA $0DB9
BIT #$01
BEQ NoSpinBuzzyShell
LDA #$00
JSR LocateContact
BNE SpinKillBuzzy
NoSpinBuzzyShell:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYBuzzy
JSR UpdatePosByCarry
LDA $0DB9
BMI +
LDA #$80
TSB $0DB9
LDA #$08
STA $154C,x
+
RTS
NoXYBuzzy:
LDA $0DB9
BPL KickBuzzyShellLR
JSR UpdatePosByCarry
JSR LetGo
RTS
KickBuzzyShellLR:
JSR SubHorzPosLuigi
PHX
TYX
LDY $0F
LDA.w LaunchBuzzyShellSpeeds,y
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

BuzzyReturn:
RTS

LaunchBuzzySpeeds:
db $20,$E0
LaunchBuzzyShellSpeeds:
db $30,$D0

Sprite12:;??????????
RTS

Sprite14:;Falling Spiny
RTS

;Horizontal/vertical fish = jumping pirannah (sprite 4F)

;Hopping fish/generated fish = jumping fish (sprite 47)

Sprite19:;Display Message Text
RTS

Sprite1B:;Bouncing football
JSR Sprite1C
RTS

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

Sprite1E:;Lakitu
JSR Sprite1C
RTS

Sprite1F:;Magikoopa
JSR Sprite1C
RTS

Sprite20:;Magikoopa Magic
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
Sprite23:;Net koopas
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


;thwonp + thwimp = jumping piranah

Sprite28:;Big Boo
RTS

Sprite29:;Koopaling
LDA $1570,x
BEQ $03
JMP KillWithStar
LDA #$00
JSR LocateContact;\if the chuck wins
BEQ KoopalingWins;/hurt player
JSR BoostSpeed
LDA #$02;\bounce sound
STA $1DF9;/
JSR Sprite1C
JSR Sprite4A
LDA $00C2,y;\if stunned
INC; |
STA $1528,y;/
CMP #$01;\if three, kill
BEQ KillKoopaling;/

LDA #$28                ;\ Play sound effect ;From chuck dissasembly
STA $1DFC               ;/
LDA #$00
JSR KillKoopaling
PHY
LDA KoopalingBounceXsp,Y
PLY
STA $00B6,x
RTS

KillKoopaling:
LDA #$02
STA $14D1,y
KoopalingBounce:
RTS

KoopalingWins:
JSR HurtLuigi
RTS

KoopalingBounceXsp:
db $20,$E0
RTS

Sprite2A:;upside down pirannah plant
JSR Sprite4F
RTS

Sprite2B:;Sumo Brother Ligth
JSR Sprite4F
RTS

Sprite2C:;Yoshi egg
RTS

Sprite2D:;Baby Green Yoshi
LDA $0DB9
BIT #$00
BEQ NoSpinegg
NoSpinegg:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYegg
JSR UpdatePosByCarry
LDA $0DB9
BMI +
LDA #$80
TSB $0DB9
LDA #$08
STA $154C,x
+
RTS
NoXYegg:
LDA $0DB9
BPL Kickegg
JSR UpdatePosByCarry
JSR LetGo
RTS
Kickegg:
JSR SolidSprite
JSR SubHorzPosLuigi
PHX
TYX
LDY $0F
LDA.w LaunchShellSpeeds,y
STA $B6,x
LDA #$0A
STA $154C,x
TXY
PLX
LDA #$80
TRB $0DB9
LDA #$13
STA $1DF9
RTS
RTS

Sprite2E:;Spike top
RTS

Sprite2F:;SpringBoard
JSR BounceNoSolid
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
JSR SolidSprite
RTS

Sprite30:;DrybonesTrowbones
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
LDA $0DB9
AND #$01
BNE DryBonesSpinKill
;JSL $01AB99
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
JSR KillDryBones
RTS
DryBonesSpinKill:
JSR SpinKillSprite
RTS
DryBonesWin:
JSR HurtLuigi
RTS
KillDryBones:
JSR KillNoSound
LDA #$07
STA $1DF9
RTS

Sprite31:;Bony
JSR Sprite30
RTS

Sprite32:;Drybones
JSR Sprite30
RTS

;jumping + boss fireballs = jumping pirranah

Sprite35:;Yoshi
LDA $0DB9
BIT #$00
BEQ NoSpinYoshi
NoSpinYoshi:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ NoXYYoshi
JSR UpdatePosByCarry
LDA $0DB9
+
RTS
NoXYYoshi:
BPL KickYoshi
JSR UpdatePosByCarry
RTS
KickYoshi:
JSR Sprite53
RTS

Sprite36:;??????????
RTS

Sprite37:;Boo
RTS

Sprite38:;Eerie
RTS

Sprite39:;Eerie Wave Motion
RTS

Sprite3A:;Urchin Fixed Vertical/Horizontal
RTS

Sprite3B:;Urchin Wall Detect Vertical/Horizontal
RTS

Sprite3C:;Urchin Wall Follow counter
RTS

Sprite3D:;Rip Van Fish
RTS

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
LDA #$FF
STA $14AD
LDA #$20
STA $1887			; Set earthquake timer
RTS
.SilverP
LDA #$FF
STA $14AE
LDA #$20
STA $1887			; Set earthquake timer
.end
RTS
RTS

Sprite3F:;Para Goomba
JSR Sprite91
RTS

Sprite40:;Para Bomb
JSR Sprite91
RTS

Sprite41:;Dolphin Long Jump Horizontal/Spiny's sprite 13-14
JSR Sprite4F
RTS

Sprite42:;Dolphin Short Jump Horizontal
JSR Sprite55
RTS

Sprite43:;Dolphin Jump Vertical
JSR Sprite55
RTS

Sprite44:;Torpedo ted
JSR Sprite4F
RTS

Sprite45:;Directional Coins
RTS

;diggin' chuck = chargin' chuck

;diggin' chuck's rock (48) = jumping pirannah

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

Sprite49:;Growing Pipe
JSR SolidSprite
RTS

Sprite4A:;Goal Point Sphere
LDY #$0C
TYX
JSL EndLevel
LDX $0F65
.end
RTS

Sprite4B:;Pipe Lakitu
JSR Sprite1C
RTS

Sprite4C:;Exploding Block, Fish/Goomba/Koopa/Sheless Koopa
JSR SolidSprite
RTS

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

Sprite4F:;Jumping Pirannah
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

;SpitFire Jumping Pirannah = Jumping pirannah

Sprite51:;Ninji
JSR Sprite1C
RTS

Sprite52:;Moving Hole/Ghost House
JSR HurtLuigi
RTS

Sprite53:;Purple TurnBloock
JSR Sprite2D
RTS

Sprite54:;rotating net door thing
RTS

Sprite55:;vertical/horizontal checkerboard platforms
Sprite57:
LDA $AA,x
BMI .end
LDA $14D4,y
STA $01
LDA $00D8,y
STA $00
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
;CLC
;ADC #$0006
CMP $00
BCS .end
LDA $00
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
LDA $009E,y
CMP #$55
BNE .end
LDA $1588,x
BIT #$03
BNE .end
LDA $1528,y
PHY
LDY #$00
PHA
PLA
BPL +
DEY
+
CLC
ADC $E4,x
STA $E4,x
TYA
ADC $14E0,x
STA $14E0,x
PLY
.end
SEP #$20
RTS

Sprite56:;Fliying Rock Plataform/Horizontal
JSR Sprite55
RTS

Sprite58:;Fliying Rock Plataform/Vertical
JSR Sprite55
RTS

Sprite59:;Turn block bridges
Sprite5A:
;LDA #$08
;TSB $0DB9
LDA #$10
STZ $0D
STA $0C;platform width
STZ $0F
STA $0E;platfrorm height
LDA $E4,x
STA $00
LDA $14E0,x;luigi X
STA $01
LDA $D8,x
CLC
ADC #$10
STA $02;luigi Y foot
LDA $14D4,x
ADC #$00
STA $03
LDA #$10;small height
STA $0A
JSR GetHeight
BEQ +
LDA #$20;big height
STA $0A
+
LDA $02
SEC
SBC $0A
STA $08;luigi y head
LDA $03
SBC #$00
STA $09
STZ $0B
LDA $00E4,y
STA $04;Platform X
LDA $14E0,y
STA $05
LDA $00D8,y
STA $06;platform Y
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

Sprite5B:;Brown Plataform Floating in water
JSR Sprite55
RTS

Sprite5C:;CheckBoard Plataform Floating in water
JSR Sprite55
RTS

Sprite5D:;Orange sinking platform
LDA $AA,x
BMI .end
LDA $D8,x
CLC
ADC #$0D
STA $00
LDA $14D4,x
ADC #$00
STA $01
LDA $14D4,y
XBA
LDA $00D8,y
REP #$20
CMP $00
BCS .end
SEC
SBC #$000F
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$40
STA $AA,x
LDA $1588,x
ORA #$04
STA $1588,x
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

Sprite5E:;Big Orange Plataform(Beta)
JSR Sprite5D
RTS

Sprite5F:			;Brown swinging plataform
REP #$20
LDA $14B8
PHA
SEC
SBC #$0022
STA $14B8
LDA $14BA
CLC
ADC #$0010
STA $0E
SEP #$20
JSR MainSwingPlat
REP #$20
PLA
STA $14B8
SEP #$20
RTS

MainSwingPlat:
LDA $AA,x
BMI .end
LDA $D8,x
STA $00
LDA $14D4,x
STA $01
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
SEC
SBC $14B8
BMI .end
CMP #$0046
BCS .end
LDA $00
CMP $0E
BCS .end
LDA $14BA
SEC
SBC #$0018
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$40
STA $AA,x
LDA #$04
ORA $1588,x
STA $1588,x
LDA $1588,x
AND #$03
BNE .end
LDA $1534,y
PHY
LDY #$00
PHA
PLA
BPL +
DEY
+
CLC
ADC $E4,x
STA $E4,x
TYA
ADC $14E0,x
STA $14E0,x
PLY
.end
RTS

Sprite60:;Flat Green Switch
JSR SolidSprite
RTS

Sprite61:;Floating Skulls
JSR SolidSprite
RTS

Sprite62:;line guided brown platform
LDA $AA,x
BMI .end
LDA $D8,x
CLC
ADC #$16
STA $00
LDA $14D4,x
ADC #$00
STA $01
LDA $14D4,y
XBA
LDA $00D8,y
REP #$20
CMP $00
BCS .end
SEC
SBC #$0016
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$20
STA $AA,x
LDA $1588,x
ORA #$04
STA $1588,x
PHX
TYX
LDA $7FAC6C,x
STA $00
STZ $01
BPL +
DEC $01
+
PLX
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
CLC
ADC $00
SEP #$20
STA $E4,x
XBA
STA $14E0,x
SEP #$20
SEC
RTS
.end
SEP #$20
CLC
RTS

Sprite63:;Checker/Bronw Plataform
JSR Sprite62
BCC +
LDA #$00
STA $1626,y
STA $1540,y
+
RTS

Sprite64:;Rope Mechanism
RTS

Sprite68:;Fuzzy Ball
RTS

Sprite69:;??????????????
RTS

Sprite6A:;Coin Game Cloud
RTS

Sprite6B:;Spring Board /Left Wall
JSR BounceNoSolid
RTS

Sprite6C:;Spring Board /Right Wall
JSR BounceNoSolid
RTS

Sprite6D:;invisible solid block
SolidSprite:
LDA $14D4,y
STA $03
LDA $00D8,y
STA $02; $02 = Block's top
STZ $04
STZ $05
JSR GetHeight
BEQ +
LDA #$0B
STA $04; $04 = Luigi's height - #$10
+
LDA $14D4,x
STA $01
XBA
LDA $D8,x
STA $00;$00 = Luigi's y-position
REP #$20
SEC
SBC $04
STA $04;$04 = Luigi's top (b/c being big doesn't change the y-position)
LDA $00
CLC
ADC #$0008
CMP $02
BCS .nottop
SEP #$20; We're standing on the block!
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
SEP #$20; We're hitting our head on the block!
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
LDA #$00; We hit nothing :(
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
JSR Sprite00
RTS

Sprite6F:;Dino Torch
JSR Sprite00
RTS

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
LDA #$0B                ;sets game mode to exit level
	STA $0100        		
	JML $00A289
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
LDA #$01			;
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
JSR GoalCheck
RTS

Sprite7C:;Secret Goal Point
RTS

Sprite7D:;P Ballon
JSR SolidSprite
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
JSL $05B34A;			|
JSL $05B34A;			|+5 coin
JSL $05B34A;			|
JSL $05B34A;			/
JSL $00BEB0
JSR BlockSparkle
RTS

;flying yellow mushroom = 1up

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

Sprite82:;bonus game thing
JSR Sprite81
RTS

Sprite83:;flying question block
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

Sprite84:;Fliying Question Block 2
JSR Sprite83
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
LDA $AA,x
BMI .end
LDA $D8,x
CLC
ADC #$0D
STA $00
LDA $14D4,x
ADC #$00
STA $01
LDA $14D4,y
XBA
LDA $00D8,y
REP #$20
CMP $00
BCS .end
SEC
SBC #$000F
SEP #$20
STA $D8,x
XBA
STA $14D4,x
LDA #$40
STA $AA,x
LDA $1588,x
ORA #$04
STA $1588,x
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

Sprite90:;Large Green Gas Bubble
JSR Sprite70
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

;ALL CHUCKS = chargin' chuck

Sprite99:;Volcano Lotus
JSR Sprite4F
RTS

Sprite9A:;Sumo
JSR Sprite4F
RTS

Sprite9B:;Hammer Brother
JSR Sprite1C
RTS

Sprite9C:;Fliying Blocks
JSR Sprite83
RTS

Sprite9D:;Bubble With a Goomba/bomb/Fish/Mushroom
LDA #$00
STA $00AA,y
STA $00B6,y
LDA #$02
STA $14C8,y		;set state to whatev~
;Boos Speed
;PHX
;TYX
JSL $01AB72		;white-star
;PLX
LDA $0DA3
ORA $0DA5
BIT #$80
BNE StopJump
LDA #$CF
STA $AA,x
RTS
StopJump:
LDA #$CF
STA $AA,x
RTS
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

SpriteA0:;Activate Bowser Ecene
JSR HurtLuigi
RTS

SpriteA1:;Bowser Bowling Ball
JSR Sprite70
RTS

SpriteA2:;Mecha koopas
JSR Sprite0F
RTS

SpriteA3:;Grey Plataform on chain
RTS

SpriteAA:;Fish Bone
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
JSR HurtLuigi
RTS

SpriteAD:;Wooden Spike Down
JSR HurtLuigi
RTS

SpriteAE:;Fishing Boo
JSR Sprite4F
RTS

SpriteAF:;Boo Block
JSR SolidSprite
RTS

SpriteB0:;Reflecting stream of Boo Buddies
JSR Sprite4F
RTS

SpriteB1:;Creating/Eating Block
JSR SolidSprite
RTS

SpriteB7:;Carrot Top lift 1
JSR SolidSprite
RTS

SpriteB8:;Carrot Top lift 2
JSR SolidSprite
RTS

SpriteB9:;Message Box
JSR SolidSprite
CMP #$02
BNE .end
LDA #$10
STA $1558,y
.end
RTS

SpriteBA:;Timed Lift 4/1Seconds
JSR SolidSprite
RTS

SpriteBB:;Grey Moving castle Block
JSR SolidSprite
RTS

SpriteBC:;Bowser Statues
JSR SolidSprite
RTS

;blue sliding koopa = green shelless koopa

SpriteBE:;?????????????
RTS

SpriteBF:;MegaMole
JSR SolidSprite
RTS

SpriteC0:;Grey Plataform on lava
JSR Sprite5D
RTS

SpriteC1:;Fliying Grey Turn Blocks
JSR SolidSprite
RTS

SpriteC4:;Grey Plataforms That Falls
JSR Sprite5D
RTS

SpriteC5:;Big Boo Boss
RTS

SpriteC6:;Dark room with spot light
RTS

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

SpriteC8:;Ligth question Block
JSR Sprite83
RTS

SpriteC9:;Bullet Bill Shoter
RTS

SpriteCA:; Torpedo Launcher
JSR Sprite4F
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
ADC #$10;10: Ducking - 20: Standing
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

.typetwo;1up, maybe more?
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
LDA $1E16,y;Boo ceiling, disappearing boos
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
LDA $190A;2 - conditional kill - $190A
SEC
SBC #$40
CMP #$A0
BCS .end
JSR HurtLuigi
RTS
+
CMP #$03
BNE +
LDA $0F86,y;3 - conditional kill - $0F86,y
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
LDA #$00;4 - 1up
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
