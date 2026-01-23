

		Align   $10
        dc.b    'PLAYERSHADOWSTRT'

ShadowEntity:
        dc.b    $00
        dc.b    $00
        dc.b    $18
        dc.b    $00
        dc.b    $03
        dc.b    $56
        dc.b    $90
        dc.b    $98
        dc.b    $FF
        dc.b    $FE						; Specific sentinel value

LoadShadowEntity:
		move.b	(a2)+,d0
		cmpi.b	#$FE,d0
		beq.w	LoShEn_end
        lea	(ShadowEntity).l,a2
		jmp	(loc_1956C).l				; Back to room entity loading loop
LoShEn_end:
        move.w	#$FFFF,(a1)
        rts

UpdatePlayerShadow:						
		movem.w	d0-d7/a0-a1,-(sp)
		lea	(Player_X).l,a0
		move.l	X(a0),d0				; Set base position : under player
		move.l	d0,X(a5)				; X, Y, SubX, SubY
		move.l	CentreX(a0),d0
		move.l	d0,CentreX(a5)			; CentreX, CentreY
		move.l	HitBoxXStart(a0),d0		; required for ordering sprites per display priority
		move.l	d0,HitBoxXStart(a5)		; HitBoxXStart, HitBoxXEnd
		move.l	HitBoxYStart(a0),d0
		move.l	d0,HitBoxYStart(a5)		; HitBoxYStart, HitBoxYEnd
		move.w	HeightmapOffset(a0),d0	; required for sprite priority flag in relation to foreground
		move.w	d0,HeightmapOffset(a5)
		move.b	GroundHeight(a0),d0
		move.b	d0,GroundHeight(a5)
		move.b	FloorHeight(a0),d0
		move.b	d0,FloorHeight(a5)
		move.w	Z(a0),d6
		move.b	d6,Z+1(a5)
		move.b	d6,HitBoxZEnd+1(a5)
        bset    #$00,AnimAction1(a5)
		move.b	(Player_Action+1).l,d0 	; Test if jumping or falling
		andi.b 	#$30,d0
		beq.s	UpPlSh_hide	
		bsr.w   ApplyDownwardSpriteCollision
		bcs.s	UpPlSh_show				; collision found with a sprite below : project shadow on sprite
		bsr.w   ApplyHeightmap			; otherwise, project shadow on map
		lea		(a5),a1
		movem.l	a5,-(sp)
		jsr		sub_44C4				; Update shadow sprite priority flag
		movem.l	(sp)+,a5
UpPlSh_show: 
		bclr    #$00,Flags1(a5)	
		bra.s   UpPlSh_end
UpPlSh_hide:	
        bset    #$00,Flags1(a5)
UpPlSh_end:
		movem.w	(sp)+,d0-d7/a0-a1
		rts	

ApplyDownwardSpriteCollision:
        movem.w	d0-d7/a0,-(sp)
		move.l	a5,d0					; initialize d0 as shadow sprite base offset from Player sprite
		subi.l	#Player_X,d0
		lea	(Player_X).l,a0				; get shadow sprite position
		move.w	HitBoxXStart(a0,d0.w),d1
		move.w	HitBoxXEnd(a0,d0.w),d2
		move.w	HitBoxYStart(a0,d0.w),d3
		move.w	HitBoxYEnd(a0,d0.w),d4
		move.w	Z(a0,d0.w),d5
		clr.w	d6						; candidate sprite Z end
		clr.w	d7						; cursor offset
		lea	SPRITE_SIZE(a0),a0			; skip Player sprite
		addi.w	#SPRITE_SIZE,d7        
ApDoSpCo_loop:	
		cmp.w	d7,d0
		beq.s	ApDoSpCo_next			; skip shadow sprite
		tst.w	X(a0)
		bmi.s	ApDoSpCo_apply			; no more sprites
		cmp.w	HitBoxXEnd(a0),d1
		bhi.s	ApDoSpCo_next			; shadow sprite X start higher than compared sprite X end : no collision
		cmp.w	HitBoxXStart(a0),d2
		bcs.s	ApDoSpCo_next			; shadow sprite X end lower than compared sprite X start : no collision
		cmp.w	HitBoxYEnd(a0),d3
		bhi.s	ApDoSpCo_next			; shadow sprite Y start higher than compared sprite Y end : no collision
		cmp.w	HitBoxYStart(a0),d4
		bcs.s	ApDoSpCo_next			; shadow sprite Y end lower than compared sprite Y start : no collision
		cmp.w	Z(a0),d5
		bcs.s	ApDoSpCo_next			; shadow sprite Z lower than compared sprite Z : no collision
		tst.b	Flags1(a0)
		bne.s	ApDoSpCo_next
		; shadow sprite is above compared sprite Z : compared sprite is a valid candidate
        cmp.w   HitBoxZEnd(a0),d6
		bhi.s   ApDoSpCo_next
		move.w	HitBoxZEnd(a0),d6		; keep highest sprite
ApDoSpCo_next:
		lea	SPRITE_SIZE(a0),a0
		addi.w	#SPRITE_SIZE,d7
		cmpi.w	#$0800,d7
		bcs.s	ApDoSpCo_loop
ApDoSpCo_apply:
		tst.b   d6
		beq.s   ApDoSpCo_noCollision
		move.w  d6,Z(a5)
		move.w  d6,HitBoxZEnd(a5)
		ori	#$01,ccr                   ; collision found : set carry
		bra.w   ApDoSpCo_end
ApDoSpCo_noCollision:
		tst.b	d0                     ; no collision found : clear carry
ApDoSpCo_end:
        movem.w	(sp)+,d0-d7/a0
		rts

ApplyHeightmap:
		lea		(a5),a0
		move.w	Z(a0),d7
		jsr		sub_3302
		move.b	d4,FloorHeight(a0)
		move.b	d4,Z+1(a0)
		rts

        Align   $10
        dc.b   'PLAYERSHADOWEND.'









