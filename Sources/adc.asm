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
        
    XDEF initADC
    XDEF convertADC
    
    XREF decToASCII, temp
    
    INCLUDE 'mc9s12dp256.inc'
    

.data: SECTION
  ;initial_measure: ds.w 1
  degree_string: ds.b 7 ;wrongly formatted string
 

.init: SECTION


; Public interface function: initADC ... Initialize ACD (called
; once in main.c before using the ADC) 
; Parameter: -
; Return: -
; Registers: Unchanged (when function returns
initADC:
  MOVB #$00,temp;
  MOVB #$C0, ATD0CTL2 ; Enable ATD, no interrupt
  MOVB #$08, ATD0CTL3 ; Single conversion only
  MOVB #$05, ATD0CTL4 ; 10 bit, 2 MHz ATD0 clock
  rts
  


; Public interface function: convertADC ... Convert analog values 0...1023 into the corresponding temperature -30�C .. 70�C
; string to LCD 
; Parameter:
; Y ... pointer points to adress of result string
; Return: correctly formated result string stored in Register Y
; Registers: Y points to result string address

convertADC:

  MOVB #$87, ATD0CTL5 ; Start conversion on channel 7

wait1:
;Wait for End of Conversion (EOC), busy waiting:
  BRCLR ATD0STAT0, #$80, wait1
  LDD ATD0DR0 ; Read conversion result � D  




;######################### Calculation happens here ##################################
  
  

  
  PSHY
  PSHX
    
  LDY #100  ;multiply by 100
  EMULS
  LDX   #1023
  EDIV
  TFR   Y, D
  SUBD  #30
  
  PULX
  PULY
  
  
;################################################################################

;convert to ASCII String
  LDX #degree_string
  JSR decToASCII
     
  LDX #degree_string  
  LDY #temp
  JSR formatString
  
  RTS 

   
  
  
  
  
formatString: ;results in a string with the format: [SIGN][digit][digit]['C']['�'][0]

  LDAA #' '  
  STAA 1, Y+
  
  LDAA 1, X+  ;copy sign
  STAA 1, Y+
    
  LDAA 3, +X  ;copy first digit
  STAA 1, Y+
    
  LDAA 1, +X  ;second digit
  STAA 1, Y+
    
  
    
  LDAA #'C'
  STAA 1, Y+
    
  LDAA #$B0;
  STAA 1, Y+
    
  LDAA #0    ;null terminator
  STAA 1, Y+
  RTS
