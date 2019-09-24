MAIN_ROUTINE:
LDA.W $13D4		;Pause Dont Animate!
BNE DORETURN
LDA $1504,x
BEQ +
JMP Animations      ; If there's an animation, redirect program flow to Animations
+
LDA $151C,x
BEQ +
DEC                 ; Count down animation timer
STA $151C,x
+
LDA $0F63
AND #$08
BEQ DeadProcessing  ; If p2 is dead or in bubble, process as such
LDA $9D
BNE DORETURN        ; If sprites locked, return
LDA $1426
BEQ Continue      ; If message box active, return

DORETURN:
JMP RETURN

DeadProcessing:
JSR DEADPROL
BRA RETURN

GravityData:
db $06,$03

Continue:
if !THREEPLAYER || !!SMALLPLAYERS
LDA $0DB9
BIT #$18
BNE +
LDA #$08                ; If small luigi, make big luigi
TSB $0DB9
+
endif
STZ $1588,x
STZ $164A,x
JSR Objects
LDA.W $13D4		;Pause Don't Move and don't interact with enemies!
BNE DORETURN
JSR Sprites
JSR ExtSprites
JSR ClusterSprites
JSR TickPhysics

NoInteraction:      ; AFAIK this label is never used?
LDA $1570,x
BNE +
STZ $0F62
+	
JSR Mechanics

RETURN:
JSR SUB_GFX
JSR DRAW_BUBBLE
LDA $142F           ; \ 
BEQ +               ;  | No idea what this is. Maybe the graphics routines use $142F
STA $1504,x         ;  | as a "change the current animation to this" flag?
STZ $142F           ; /
+
RTS
