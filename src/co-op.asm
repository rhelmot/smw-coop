incsrc simjack.asm				;hex edits/hijacks that don't use freespace
incsrc statusbar.asm			;modification to the status bar/OW border

org $009322
autoclean JML EverySingleFrame			;primary hijack - label found in prepstuff.asm

freecode
print "Inserted at $", pc

incsrc prepstuff.asm			;a big switch() for the game modes
incsrc mainrun.asm				;the primary spread of code
incsrc deadcode.asm				;code to execute while dead
incsrc graphics.asm				;graphics routines
incsrc dma.asm					;Vblank code for DMAing stuff
incsrc animations.asm			;handling for $1504,x
incsrc miscroutines.asm			;misc. JSR routines
incsrc mechanics.asm			;incl. goal walking, controls, fireballs, etc.
incsrc mariocode.asm			;code that affects mario
incsrc sprites.asm				;sprite tables and routines - WIP
incsrc objects.asm				;object interaction - WIP
incsrc afterthoughts.asm		;lots of random hijacks, routines
incsrc score.asm				;fixes for score sprites

ExGraphics:
incbin ../graphics/ExtendGFX.bin

print "Used ",freespaceuse," bytes"
