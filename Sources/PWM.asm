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
    XREF PWME,PWMPOL,PWMCTL,PWMCLK,PWMPRCLK,PWMCAE,PWMSCLA,PWMSCLB,PWMPER0,PWMPER1,PWMPER4,PWMPER5,PWMDTY0,PWMDTY1,PWMDTY4,PWMDTY5,PIEP,PPSP   
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
  MOVB #$22,PIEP
  ;Trigger on pos. Edge of P1
  MOVB #$22,PPSP; 
  ;PWM Enable for 0,1 and 4,5
  MOVB #$33,PWME;
  ;PWM Polarity
  MOVB #$00,PWMPOL
  ;PWM Clock Select : B/SB,B/SB,A/SA,A/SA,B/SB,B/SB,A/SA,A/SA
  MOVB #$33,PWMCLK ;Select SA for Channel 0 and 1
  ;PWM Prescale Clock Select 4bit B , 4bit A
  MOVB #$07,PWMPRCLK ;Prescalefactor Clock A 128
  ;PWM Center Align Enable
  MOVB #$00,PWMCAE
  ;PWM Control switch from 8bit to 16bit concat 67,45,23,01,StopInWait,StopInFreeze,0,0
  MOVB #$50,PWMCTL ;Concat Register 0 and 1
  ;PWM Scale A for SA SA=A/(2*PWMSCLA)
  MOVB #$32,PWMSCLA ;PWM Scale 50, Total Prescale = 128 * 2 * 50 = 12800
  ;PWM Scale B for SB SB=B/(2*PWMSCLB)
  MOVB #$00,PWMSCLB
  ;PWM Channel Period Register Period=Clock * RegisterValue, Each Channel has its own Register


  ;Magic Number here is 1875 which is 0x0753
  MOVB #$07,PWMPER0 ;High Byte of 16 bit count
  MOVB #$53,PWMPER1 ;Low Byte of 16 bit count
  ;PWM Duty Register Uptime is Uptime=([PWMPER-PWMDTY]/PWMPER)*100%
  ;20% Duty Cycle magic Number is 375
  MOVB #$01,PWMDTY0 ;High Byte of Duty Count
  MOVB #$77,PWMDTY1 ;Low Byte of Duty Count
  ;In Total 20% Duty Time of left aligned PWM Signal with 1875 Countdown with 12800 prescaler = One Edge every 24.000.000 Cycles = 1s
  ;Output Channel is PWM1
  ;Magic Number here is 18750 which is 0x493E
  MOVB #$49,PWMPER4
  MOVB #$3E,PWMPER5
  ;20% Duty Cycle magic Number is 3750 which is 0x0EA6 
  MOVB #$0E,PWMDTY4 ;High Byte of Duty Count
  MOVB #$A6,PWMDTY5 ;Low Byte of Duty Count
  ;In Total 20% Duty Time of left aligned PWM Signal with 1875 Countdown with 12800 prescaler = One Edge every 24.000.000 Cycles = 1s
  ;Output Channel is PWM5
  RTS
  
 
  
  
  
  