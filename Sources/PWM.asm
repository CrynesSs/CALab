;   Labor 1 - Problem 2.4
;   Convert a zero-terminated ASCIIZ string to lower characters
;   Subroutine toLower
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, HS-Esslingen
;            (based on code provided by J. Friedrich, W. Zimmermann)
;   Modified: -
;

; export symbols
    XDEF setupPWM
    XREF PWME,PWMPOL,PWMCTL,PWMCLK,PWMPRCLK,PWMCAE,PWMSCLA,PWMSCLB,PWMPER0,PWMPER1,PWMDTY0,PWMDTY1,PIEP,PPSP   
    XREF DDRP     

; Defines

; RAM: Variable data section
.data: SECTION
  
  

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION
  
  setupPWM:
  MOVB #$FF,DDRP;Set Port P as Output
  ;Port P Interrupt Enable
  MOVB #$02,PIEP
  ;Trigger on pos. Edge of P1
  MOVB #$02,PPSP; 
  ;PWM Enable
  MOVB #$03,PWME;
  ;PWM Polarity
  MOVB #$00,PWMPOL
  ;PWM Clock Select : B/SB,B/SB,A/SA,A/SA,B/SB,B/SB,A/SA,A/SA
  MOVB #$03,PWMCLK ;Select SA for Channel 0 and 1
  ;PWM Prescale Clock Select 4bit B , 4bit A
  MOVB #$07,PWMPRCLK ;Prescalefactor Clock A 128
  ;PWM Center Align Enable
  MOVB #$00,PWMCAE
  ;PWM Control switch from 8bit to 16bit concat 67,45,23,01,StopInWait,StopInFreeze,0,0
  MOVB #$10,PWMCTL ;Concat Register 0 and 1
  ;PWM Scale A for SA SA=A/(2*PWMSCLA)
  MOVB #$02,PWMSCLA ;PWM Scale 2, Total Prescale = 256
  ;PWM Scale B for SB SB=B/(2*PWMSCLB)
  MOVB #$00,PWMSCLB
  ;PWM Channel Period Register Period=Clock * RegisterValue, Each Channel has its own Register
  MOVB #$B7,PWMPER0 ;High Byte of 16 bit count
  MOVB #$1B,PWMPER1 ;Low Byte of 16 bit count
  ;PWM Duty Register Uptime is Uptime=([PWMPER-PWMDTY]/PWMPER)*100%
  MOVB #$24,PWMDTY0 ;High Byte of Duty Count
  MOVB #$9F,PWMDTY1 ;Low Byte of Duty Count
  ;In Total 20% Duty Time of left aligned PWM Signal with 46,875 Countdown with 256 prescaler = One Edge every 12.000.000 Cycles = 0.5s
  ;Output Channel is PWM1
  RTS
  
 
  
  
  
  