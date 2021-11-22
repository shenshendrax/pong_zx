; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)
                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+
; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application

AppEntry                ld ix, dir                ;
                        ld a,71                         ; white ink (7) black paper (0), bright on (64)=71
                        ld (23693),a                    ; set our screen colours.
                        xor a                           ; clear register A
                        ld a,3                          ; 2 is the code for magenta.
                        call 8859                       ; set permanent border colours.                      ;
                        call 3503                       ; ROM routine - clears screen, opens channel#2.
                        ld hl,21+0*256                  ; load hl pair with starting co-ords.
                        ld (playerx),hl                 ; set player coords.


mainloop:               call DELAY1                     ;
                        call base_xy                    ; set the x and y positions of the player.
                        call wspace                     ;
                        call enemy_xy                   ;
                        call wspace                    ;
                        call ball_xy
                        jp moveball
                        call wspace
                        call readkeys                   ;
                        jp moveenemy                    ;

moveball:
                        ld a, (ix+3)
                        and a
                        cp 21
                        jr nz, cont1
                        ld a,(ix+5)
                        ld a,-1
                        ld (ix+5), a
                        jp cont2


cont1:
                        ld a, (ix+3)
                        and a
                        cp 0
                        jr nz, cont2
                        ld a,(ix+5)
                        ld a, 1
                        ld (ix+5), a

cont2:                  ld a, (ix+4)
                        and a
                        cp 0
                        jr nz, cont3
                        ld a,(ix+6)
                        ld a,1
                        ld (ix+6),a
                        jp cont4                     ; here

cont3:
                        ld a, (ix+4)
                        and a
                        cp 30
                        jr nz, cont4
                        ld a,(ix+6)
                        ld a,-1
                        ld (ix+6),a




cont4:
                        ld a, (ix+3)
                        add (ix+5)
                        ld (ix+3),a
                        ld a, (ix+4)
                        add (ix+6)
                        ld (ix+4),a
                        jp cont9

cont9:                  call wspace
                       call readkeys                   ;
                       jp moveenemy                    ;


cont:                   call ball_xy
                        call ball
                        call wspace
                        call base_xy                    ; set the x and y positions of the player.
                        call player1                    ; show player.
                        call enemy_xy                   ;
                        call enemy1                     ;


drawmiddleline:         ld a,7                          ; white colour on black. bright
                        ld (23695),a                    ; set our temporary screen colours.
                        ld a,21                         ; row 21 = bottom of screen.
                        ld (lxcord),a                   ; init x coord.
lineloop:               call setxy                      ; set up our x/y coords.
                        ld a,124                        ; want an line UDG char here.
                        rst 16                          ; display it.
                        call setxy                      ; set up our x/y coords.
                        ld hl,lxcord                    ; vertical position.
                        dec (hl)                        ; move it up one line.
                        dec (hl)                        ; move it up one line.
                        ld a,(hl)                       ; where is it now?
                        cp $FF                          ; past top of screen yet?
                        jr nz,lineloop                  ; no, carry on.
                        jp mainloop                     ;

readkeys:               ld bc,63486                     ; keyboard row 1-2.
                        in a,(c)                        ; see what keys are pressed.
                        rra                             ; next bit (value 1) = key 1.
                        push af                         ; remember the value.
                        call nc,movedown                ; being pressed, so move down.
                        pop af                          ; restore accumulator.
                        rra                             ; next bit (value 8) reads key 2.
                        call nc,moveup                  ; it's being pressed, move up.
                        ret                             ;


setxy:                   ld a,22                         ; ASCII control code for 'AT'.
                        rst 16                          ; print it.
                        ld a,(lxcord)                   ; vertical position.
                        rst 16                          ; print it.
                        ld a,(lycord)                   ; y coordinate.
                        rst 16                          ; print it.
                        ret                             ;

enemy_xy:               ld a,22                         ; AT code.
                        rst 16                          ;
                        ld a,(ix+1)                 ; player vertical coord.
                        rst 16                          ; set vertical position of player.
                        ld a,(ix+2)                   ; player's horizontal position.
                        rst 16                          ; set the horizontal coord.
                        ret                             ;

base_xy:                ld a,22                         ; AT code.
                        rst 16                          ;
                        ld a,(playerx)                  ; player vertical coord.
                        rst 16                          ; set vertical position of player.
                        ld a,(playery)                  ; player's horizontal position.
                        rst 16                          ; set the horizontal coord.
                        ret                             ;

ball_xy:                ld a,22                         ; AT code.
                        rst 16                          ;
                        ld a,(ix+3)                  ; player vertical coord.
                        rst 16                          ; set the horizontal coord.
                        ld a,(ix+4)                  ; player vertical coord.
                        rst 16                          ; set the horizontal coord.
                        ret                             ;



moveenemy:              ld a,32                         ;
                        rst 16                          ;
                        ld a,(ix+0)                     ; IX+6 =direction, binary choice, =0 goes up, =1 goes down.
                        and a                           ;
                        jr nz, moveenemydown            ;                ;
moveenemyup:            dec (ix+1)                      ; move up
                        LD a, (ix+1)                    ; store new pos val                         ;
                        cp 0                            ; at top?
                        jr z, switchdown               ;
                        jp cont                         ;
moveenemydown:          inc (ix+1)                      ;  move down
                        ld a, (ix+1)                    ; Store new co-ordinate                           ;
                        cp 20                           ; at bottom?
                        jr z, switchup                 ;
                        jp cont                         ;
switchup:               ld (ix+0), 0                    ;   possible to combine into single
                        jp  cont                         ;   routine that NOT's the value
switchdown:             ld (ix+0), 1                    ;
                        jp  cont


moveup:                  ld hl,playerx                   ; remember, x is the vertical coord!
                        ld a,(hl)                       ; what's the current value?
                        cp 0                            ; is it at upper limit (4)?
                        ret z                           ; yes - we can go no further then.
                        dec (hl)                        ; subtract 1 from x coordinate.
                        ret                             ;
movedown:                ld hl,playerx                   ; remember, x is the vertical coord!
                        ld a,(hl)                       ; what's the current value?
                        cp 21                           ; is it already at the bottom (21)?
                        ret z                           ; yes - we can't go down any more.
                        inc (hl)                        ; add 1 to x coordinate.
                        ret                             ;                                              ;

                        jp mainloop

; Set up the x and y coordinates for the player's gunbase position,
; this routine is called prior to display and deletion of gunbase.

                        ;

; Show player at current print position.

player1:                 ld a,71                         ; white colour on black. bright
                        ld (23695),a                    ; set our temporary screen colours.
                        ld a,133                        ; ASCII code for User Defined Graphic 'A'.
                        rst 16                          ; draw player.
                        ret                             ;


enemy1:                  ld a,71                          ; white colour on black. bright
                        ld (23695),a                    ; set our temporary screen colours.
                        ld a,138                        ; ASCII code for User Defined Graphic 'A'.
                        rst 16                          ; draw player.
                        ret                             ;

ball:                   ld a,71                          ; white colour on black. bright
                        ld (23695),a                    ; set our temporary screen colours.
                        ld a,111                        ; ASCII code for User Defined Graphic 'A'.
                        rst 16                          ; draw player.
                        ret                             ;



wspace:                  ld a,0                          ; black on black paper (0)
                        ld (23695),a                    ; set our temporary screen colours.
                        ld a,32                         ; SPACE character.
                        rst 16                          ; display space.
                        ret                             ;


DELAY1                  ld b,6                         ; Delay length
DELAYLOOP               halt                            ;
                        djnz DELAYLOOP                  ; Decrease B by one and repeat until B is zero
                        ret                             ;



playerx                 defb 10                         ; player's x coordinate.
playery                 defb 2                          ; player's y coordinate.
lxcord                  defb 0                          ; bottom most line on screen
lycord                  defb 15                         ; approx middle of screen



dir                     defb 0                          ;      ix+0
dir_x                   defb 10                         ;      ix+1
enemyy                  defb 31                         ;      ix+2
ballX                   defb 10                        ;      ix+3
ballY                   defb 10                       ;     ix+4
vecX                    defb 1                           ;     ix+5
vecY                    defb 1                           ;     ix+6


; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1 ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                    ; Tell the emulator where to start
Zeus_SP                 equ $FF40                       ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader



