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
    XREF updateThermo;
    XREF tick,PIFP,setupNames,changeName,displayTemperatureAndTime,writeLine;
    XREF FRAME_BUFFER,LINE_BUFFER;
    
    
.init: SECTION
;**************************************************************
; Interrupt handler for the PWM module Interrupts that are used as timers here
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
;**************************************************************    
  handleClockTick:
    ;Jump to Clock Subroutine
    MOVB #$02,PIFP;Reset Interrupt Flag
    JSR tick;
    ;JSR updateThermo;
    JSR displayTemperatureAndTime;
    BRA continueInterruptHandle;
;**************************************************************
  swapNames:
    MOVB #$20,PIFP;Reset Interrupt Flag
    ;JSR changeName;
    BRA continueInterruptHandle2
;**************************************************************
  displayName:
    MOVB #$08,PIFP;Reset Interrupt Flag
    ;JSR setupNames;
    BRA continueInterruptHandle3;
