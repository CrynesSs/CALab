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
    XREF tick,PIFP,displayNames,changeName;
    
    
.init: SECTION
  handlePWMITR:
    ;This is the check for the 1s pwm timer
    BRSET PIFP,#$02,handleClockTick;
    continueInterruptHandle:
    ;This is the check for the 10s pwm timer
    BRSET PIFP,#$20,swapNames;
    continueInterruptHandle2:
    BRSET PIFP,#$08,displayName;
    continueInterruptHandle3:
    RTI;
  handleClockTick:
    ;Jump to Clock Subroutine
    JSR tick;
    BRA continueInterruptHandle;
  swapNames:
    JSR changeName;
    BRA continueInterruptHandle2
  displayName:
    JSR displayNames;
    BRA continueInterruptHandle3;
