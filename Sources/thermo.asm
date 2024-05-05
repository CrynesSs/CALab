    XDEF initThermo
    XDEF updateThermo
    XDEF temp
    
    XREF initADC
    XREF convertADC
     
    INCLUDE 'mc9s12dp256.inc'
.data: SECTION
temp: ds.b 7 ;


.init: SECTION

initThermo:
  JSR initADC  
  rts
  


updateThermo: ;
  PSHB
  PSHY
  PSHX
  
  LDY #temp
  JSR convertADC

  PULX
  PULY
  PULB
 
  rts