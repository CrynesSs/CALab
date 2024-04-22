;   Labor 1 - Vorbereitungsaufgabe 2.4
;   Convert a zero-terminated ASCIIZ string to lower characters
;   Main program
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, Jul 4, 2019
;            (based on code provided by J. Friedrich, W. Zimmermann)
;   Modified: -
;

; export symbols
        XDEF COUNT_UP_BY_2
        XREF PORTB,PIFP,COUNT 
        XREF hexToASCII;
        XREF decToASCII;
        XREF setLED;
        XREF PTH,writeLine
; RAM: Variable data section
.data:  SECTION
 i: ds.w  1
 msgDec: ds.b 7  
 msgHex: ds.b 7
; ROM: Constant data
.const: SECTION
MSG1:   dc.b " Mach mal eine",0
MSG2:   dc.b " kleine Pause",0
msgA:   DC.B "ABCDEFGHIJKLMnopqrstuvwxyz1234567890",0  ;on line 0
msgB:   DC.B "is this OK?",0                           ;on line 1
 
.init: SECTION
  RESET:  
        MOVB #$00,COUNT
        LDAA COUNT                       ; Reset counter to 0
        STAA PORTB                      ;
        BRA outputLED;         ; Wait for half a Second         
        

  COUNT_UP_BY_2:
        MOVB #$02,PIFP;Reset Interrupt Flag
        LDAA COUNT;                     ;
        ADDA #$02                       ; Increment by 2
        CMPA #$3F                       ; Compare with 63 
        BHS RESET                       ; If greater or equal 63 -> Roll Over (we can never hit 63 so it does not matter if greater | greater/equal)  
    outputLED:                          ;
        STAA COUNT                      ; Store incremented low byte back to counter 
        STAA PORTB                      ; 
        RTI        
        
        
    main_loop:
        MOVB #$02,PIFP;Reset Interrupt Flag
        
        LDX #msgDec
        LDD i
        JSR decToASCII
        
        LDX #msgHex
        LDD i
        JSR hexToASCII
        
        
        
        LDX #msgDec
        LDAB #0
        JSR writeLine
        
        LDX #msgHex
        LDAB #1
        JSR writeLine
        
        LDD i
        JSR setLED                                 
        
        
        BRSET PTH, #$01, button0pressed ; check if button on port PTH.0
        BRSET PTH, #$02, button1pressed ; check if button on port PTH.1
        BRSET PTH, #$04, button2pressed ; check if button on port PTH.2
        BRSET PTH, #$08, button3pressed ; check if button on port PTH.3
    

        ; continue here if not pressed
        ;increment i by 1
        LDD i
        ADDD #1
        STD i
        RTI;                                
        

button0pressed:
        LDD i
        ADDD #16
        STD i
        RTI

button1pressed:
        LDD i
        ADDD #10
        STD i
        RTI
        


button2pressed:
        LDD i
        SUBD #16
        STD i
        RTI
        


button3pressed:
        LDD i
        SUBD #10
        STD i
        RTI    