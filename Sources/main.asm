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
        XDEF PORTB, DDRB, DDRJ, PTJ, DDRP, PTP,PTH,DDRH,PPSH,PIEH,PTH_PTH0,PERH
        XDEF TC1,TCTL1,TCTL2,TCTL3,TCTL4,TIOS,TSCR1,TSCR2,TFLG1,TIE
        XDEF PWME,PWMPOL,PWMCTL,PWMCLK,PWMPRCLK,PWMCAE,PWMSCLA,PWMSCLB,PWMPER0,PWMPER1,PWMDTY0,PWMDTY1,PWMPER4,PWMPER5,PWMDTY4,PWMDTY5,PIEP,PPSP,PIFP
        XDEF PIFH,TC0,TFLG1,PPSH,TCNT;
        XDEF PWMPER2,PWMDTY2,writeLine
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
        XREF initNamechanger,initButtonState,setupTimer;
        XREF initADC;
        
; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

; Defines


                                      ;

.vect:SECTION
  ORG $FF8E
  DC.W handlePWMITR;
  
  ORG $FFCC
  int25:  DC.W buttonHandle;



; ROM: Code section
.init:  SECTION




main:                                   ; Begin of the program
Entry:
        LDS  #__SEG_END_SSTACK          ; Initialize stack pointer
        CLI                             ; Enable interrupts, needed for debugger
        
        JSR delay_10ms;
        JSR delay_10ms;

        JSR initLED;
        JSR initLCD;
        JSR initNamechanger;
        JSR initADC;
        JSR setClock;
        JSR initButtonState;
        JSR setupPWM;
        JSR setupTimer;
        
        
        
        

        BRA BUSY;
        


BUSY:
  BRA BUSY;          
            