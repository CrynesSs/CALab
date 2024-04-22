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
        XDEF PWME,PWMPOL,PWMCTL,PWMCLK,PWMPRCLK,PWMCAE,PWMSCLA,PWMSCLB,PWMPER0,PWMPER1,PWMDTY0,PWMDTY1,PWMPER4,PWMPER5,PWMDTY4,PWMDTY5,PIEP,PPSP,PIFP
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
        XREF handlePWMITR,setClock;
        XREF buttonHandle;
        
; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

; Defines


                                      ;

.vect:SECTION
  ORG $FF8E
  DC.W handlePWMITR
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
        JSR setClock;
        JSR initLCD;
        JSR setupPWM;
        
        
        ;Enables Interrupts on Port H which is probably the buttons connections
        MOVB #$00,DDRH
        MOVB #$0F,PPSH  
        MOVB #$0F,PIEH 
        
        
        
        
        BRA BUSY;
        


BUSY:
  BRA BUSY;          
            