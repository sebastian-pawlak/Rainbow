; "Rainbow", Atari XL/XE Intro 256B
; code by tr1x
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2019-12-07

	org $0600

gtia10	equ $80		; graphics 10 (GTIA mode)
rtclok	equ $0012
memdl1	equ $00cb
memvp1	equ $00cf
memvp2	equ $00d1
mem	equ $00d3
gprior	equ $026f
vidptr	equ $4000	; video memory
dlist	equ $9c20	; display list
colpm1	equ $d013
random	equ $d20a
wsync	equ $d40a
vcount	equ $d40b
setvbv	equ $e45c
xitvbv	equ $e462

	; prepare display list
	ldx #<dlist+3
	stx memdl1
	lda #>dlist
	sta memdl1+1
	ldy #<vidptr	; set y to zero
	sty memvp1
	sty memvp2	; for drawing horizontal bars procedure
	lda #>vidptr
	sta memvp1+1
	sta memvp2+1
	ldx #$c0
loopa1	lda #$4f	; ANTIC command: gr.mode | address
	sta (memdl1),y
	inc memdl1
	;bne skipa1	; not needed,
	;inc memdl1+1	; ..since does not occur in practice
skipa1	lda memvp1
	sta (memdl1),y
	inc memdl1
	bne skipa2
	inc memdl1+1
skipa2	lda memvp1+1
	sta (memdl1),y
	inc memdl1
	bne skipa3
	inc memdl1+1
skipa3	lda memvp1
	clc
	adc #$40
	sta memvp1
	bne skipa4
	inc memvp1+1
	lda memvp1+1
	cmp #$42
	bne skipa4
	lda #$40
	sta memvp1+1
skipa4	dex
	bne loopa1

	;lda #$41	; jump to the beginning of display list
	;sta dlist+$243	; ..is not necessary
	;lda #<dlist
	;sta dlist+$244
	;lda #>dlist
	;sta dlist+$245

	; set GTIA graphics mode
	lda #gtia10
	sta gprior

	; draw horizontal bars
	ldx #$88
loopb1	ldy #$27
loopb2	tya
	lsr
	txa
	bcs skipb1
	sec
	sbc #$11
	eor #%01110111
	clc
	adc #$11	
skipb1	sta (memvp2),y
	dey
	bpl loopb2
	lda memvp2
	;clc		; not needed in practice
	adc #$40
	sta memvp2
	bne skipb2
	inc memvp2+1
skipb2	txa
	sec
	sbc #$11
	tax
	bne loopb1

	; color palette animation
anim	lda vcount
loopc1	cmp vcount
	beq loopc1
	clc
	adc #$02
	and #%00000011
	bne anim
	sta wsync
	lda vcount
	lsr
	lsr
	asl
	asl
	asl
	asl
	tax
	lda rtclok+1
	lsr
	bcs skipc1
	lsr
	bcs skipc2
	ldx rtclok+2
	bcc skipc1	; 1 byte less than "jmp skipc1"
skipc2	lda rtclok+2
	asl
	asl
	asl
	asl
	sta mem
	txa
	clc
	adc mem
	tax
skipc1	txa
	clc
	adc #$02
	sta colpm1+1
	clc
	adc #$02
	sta colpm1+2
	clc
	adc #$02
	sta colpm1+3
	clc
	adc #$02
	sta colpm1+4
	clc
	adc #$02
	sta colpm1+5
	clc
	adc #$02
	sta colpm1+6
	clc
	adc #$02
	sta colpm1+7
	txa
	sta colpm1+0
	jmp anim
