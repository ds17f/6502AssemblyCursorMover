
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
    JSR readKeyboard
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

readKeyboard:
    LDA $FF     ; keypress is located here
    LDX #$00    ; clear the keypress
    STX $FF     ; clear the keypress

    ; keypress values are the hex ascii codes
    ; so we can just look them up

    left:
        CMP #$61    ; is 'a'?
        BNE right
        ; store the offset - 1
        RTS

    right:
        CMP #$64    ; is 'd'?
        BNE up 
        ; store the offset + 1
        LDX #$01
        STX $13
        JSR calculateOffset
        RTS

    up: 
        CMP #$77    ; is 'w'?
        BNE down
        RTS

    down: 
        CMP #$73    ; is 's'?
        ; no branch, just exit
        BNE finishKeyboard

        ; store the offset + 20
        LDX #$20
        STX $13
        JSR calculateOffset
        RTS
    
    finishKeyboard:
        ; TODO: anything else?
RTS


calculateOffset:
    ; store the old address before we change it
    LDY $10         ; load the low byte
    STY $15         ; store a copy of the low byte
    LDY $11         ; load the high byte
    STY $16         ; store a copy of the high byte

    ; TODO: need to make this able to do 16 bit logic, bounds check, etc...
    LDA $10         ; load the low byte of the screen address
    CLC             ; clear the carry flag because we're going to need it
    ADC $13         ; add the offset to the accumulated value (and track the carry)
    STA $10         ; write the low byte back to memory
    BCC noCarry    ; if the carry flag isn't set we skip the carry logic 
        LDX $11         ; Load the high byte into x
        INX             ; increment x to cover the carry
        CLC
        STX $11         ; store the high byte back
    noCarry:



    LDA #$00    ; setup a clear for the offset (because we've used it)
    STA $13     ; clear the offset (because we've used it)
RTS

