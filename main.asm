
; ===== Memory Map information ======
; Local Variables:  $00 - $0F
;
; Global Variables: $10 - xxx
;   $10 = Cursor Position (16 bit addr)
;   $12 = Cursor Color
;   $13 = Cursor Offset
;   $14 = Background Color
;   $15 = Old Address (16 bit addr)
; ===================================


; ====== Screen Info ================
; starts at $0200 - $0544
; line length is 32 pixels
; total pixels is 1024
; 32 lines
; scree is 32x32

; -- Main program initialization -- ;
init:
    ; init the cursor position to the center of the screen
    ; 6502 is little endian, low/high
    LDA #$10    ; load the low byte
    STA $10     ; store the low byte
    LDA #$04    ; load the high byte
    STA $11     ; store the high byte

    ; init the cursor offset to 0
    LDA #$00    ; init to 0
    STA $13     ; store the offset

    ; init the color to white
    LDA #$01     ; init the color to white
    STA $12     ; store to the color mem addr

    ; init the background color
    LDA #$00    ; init the background to black
    STA $14     ; store to the color mem addr

; -- Main Program Loop --
main:
    JSR readArrow
    JSR draw
    ; TODO: Stuff
    ; TODO: Stuff
JMP main


draw:
    LDY #$00        ; just use the address that we've stored, we've already calculated the offset

    ; clear the current position
    LDA $14         ; get the current background color 
    STA ($15),Y     ; store it in the old cursor position

    ; draw the new position
    LDA $12         ; get the current cursor color 
    STA ($10),Y     ; store it in the current cursor position
RTS

readArrow:
    LDA $FF     ; arrow is located here

    left:
        CMP #$61    ; is left?
        BNE right
        ; store the offset - 1
        RTS

    right:
        CMP #$64    ; is right?
        BNE up 
        ; store the offset + 1
        LDX #$01
        STX $13
        JSR calculateOffset
        RTS

    up: 
        CMP #$77    ; is up?
        BNE down
        RTS

    down: 
        LDA $FF     ; arrow is located here
        CMP #$73    ; is down?
        ; no branch, just exit
        ; store the offset + 20 (a new line)
        LDX #$20
        STX $13
        JSR calculateOffset
        RTS

    ; clear the arrow
    LDX #$00    ; clear the arrow
    STX $FF     ; clear the arrow
RTS


calculateOffset:
    ; store the old address before we change it
    LDY $10
    STY $15
    LDY $11
    STY $16

    ; TODO: need to make this able to do 16 bit logic, bounds check, etc...
    LDA $10     ; load the low byte of the screen address
    CLC         ; clear the carry flag because we're going to need it
    ADC $13     ; add the offset to the accumulated value (and track the carry)
    STA $10     ; write the low byte back to memory
    ; TODO: need to figure out how to process the carry flag and write the high byte
    LDA #$00    ; setup a clear for the offset (because we've used it)
    STA $13     ; clear the offset (because we've used it)
RTS

