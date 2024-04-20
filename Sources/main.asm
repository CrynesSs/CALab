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
        XDEF Entry, main
        XDEF PORTB, DDRB, DDRJ, PTJ, DDRP, PTP
        XDEF TC1,TCTL1,TCTL2,TIOS,TSCR1,TSCR2,TFLG1
        XDEF PWME,PWMPOL,PWMCTL,PWMCLK,PWMPRCLK,PWMCAE,PWMSCLA,PWMSCLB,PWMPER0,PWMPER1,PWMDTY0,PWMDTY1,PIEP,PPSP,PIFP
        XDEF PIFH,TC0,TFLG1,PPSH,TCNT;
; import symbols
        XREF __SEG_END_SSTACK           ; End of stack
        
        XREF toLower,strCpy             ; Referenced from other object file
        XREF initLED,setLED,getLED,toggleLED
        XREF hexToASCII;
        XREF decToASCII;
        XREF initLCD,writeLine;
        XREF setupPWM;
        XREF delay_10ms
        XREF tick,setClock;
        XREF buttonHandle;
        
; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

; Defines

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
                                      ;

.vect:SECTION
  ORG $FF8E
  DC.W tick
  ORG $FFCC
  DC.W buttonHandle



; ROM: Code section
.init:  SECTION




main:                                   ; Begin of the program
Entry:
        LDS  #__SEG_END_SSTACK          ; Initialize stack pointer
        CLI                             ; Enable interrupts, needed for debugger
        JSR delay_10ms;
        JSR delay_10ms;

        JSR initLED;
        JSR setupPWM;
        JSR initLCD;
        JSR setClock;
        
        MOVB #$00,DDRH
        MOVB #$0F,PPSH  
        MOVB #$0F,PIEH 
        
        
        MOVW #-2000, i
        
        BRA BUSY;
        
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

BUSY:
  BRA BUSY;          
            