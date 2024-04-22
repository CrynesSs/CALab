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
    XDEF handlePWMITR;
    XREF tick,PIFP
    
    
.init: SECTION
  handlePWMITR:
    BRSET PIFP,#$02,handleClockTick;
    continueInterruptHandle:
    BRSET PIFP,#$20,swapNames;
    RTI;
  handleClockTick:
    JSR tick;
    BRA continueInterruptHandle;
  swapNames:
    MOVB #$20,PIFP;Reset Interrupt Flag
    RTI;TODO implement Swapnames Logic in new File