; ##########################################
; ####   Two player cooperative play    ####
; ####  A patch for Super Mario World   ####
; ##########################################

; Patch by Andrew Dutcher (Noobish Noobsicle, rhelmot)
; Insert with asar - Requires ~20,000 bytes of freespace in basic state

; Adjust the following variables to taste. 0 = False, 1 = True

!THREEPLAYER = 1					; "Three player" mode
	; 3p mode isn't actually 3p co-op but rather a mode where there are three characters and which ones
	; you play as depend on which save file you chose. Uses a /very/ different graphics format, which
	; requires (implies) the SMALLPLAYERS flag to be FALSE.

!PLAYERKNOCKBACK = 1				; Use a knockback effect on player injury
!SMALLPLAYERS = 0					; Allow players to have the "small mario" state

org $009322
autoclean JML EverySingleFrame			;primary hijack - label found in prepstuff.asm

freecode
print "Inserted at $", pc

incsrc src/prepstuff.asm			;a big switch() for the game modes
incsrc src/mainrun.asm				;the primary spread of code
incsrc src/deadcode.asm				;code to execute while dead
incsrc src/graphics.asm				;graphics routines
incsrc src/dma.asm					;Vblank code for DMAing stuff
incsrc src/animations.asm			;handling for $1504,x
incsrc src/miscroutines.asm			;misc. JSR routines
incsrc src/mechanics.asm			;incl. goal walking, controls, fireballs, etc.
incsrc src/mariocode.asm			;code that affects mario
incsrc src/sprites.asm				;sprite tables and routines - WIP
incsrc src/objects.asm				;object interaction - WIP
incsrc src/afterthoughts.asm		;lots of random hijacks, routines
incsrc src/score.asm				;fixes for score sprites
incsrc src/simjack.asm				;hex edits/hijacks that don't use freespace
incsrc src/statusbar.asm			;modification to the status bar/OW border

ExGraphics:
incbin graphics/ExtendGFX.bin



print "Used ",freespaceuse," bytes"
