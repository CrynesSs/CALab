






.data: SECTION
HIGHS: DC.W 1
TOTAL_POLLS: DC.W 1
;0 if false 1 if true
STOP_BIT_FOUND: DC.B 1
OVER_UNDER_20: DC.B 1

;STOP_BYTE_MODE_STAT0 & STOP_BYTE_MODE_STAT1 = 1.Wait till count reaches 980/1000 == 3
;STOP_BYTE_MODE_STAT0 & !STOP_BYTE_MODE_STAT1 = 2.Wait till count stays over 980 for 20 polls. == 2
;!STOP_BYTE_MODE_STAT0 & STOP_BYTE_MODE_STAT1 = 3.wait till count goes under 980 for 20 polls. == 1
;!STOP_BYTE_MODE_STAT0 & !STOP_BYTE_MODE_STAT1 = UNUSED. == 0
EVAL_BYTE: DC.B 1 ; [STOP_BYTE_MODE_ENABLE,STOP_BYTE_MODE_STAT0,STOP_BYTE_MODE_STAT1,CONF_STOP_EVAL,NONE,CONF_I0,CONF_I1]

.const: SECTION
CONF_STOP: DS.W 1 ; 980+ 0x03D4
CONF_I0: DS.W 2 ; [920,880] , [0x0398,0x0370]
CONF_I1: DW.W 2 ; [820,780] , [0x0334,0x030C]


.init: SECTION

    poll_signal:
    LDD TOTAL_POLLS;
    CPD #1000;
    BLT continue_polling;
    ; Here we can be sure TOTAL_POLLS == 1000
    LDAB STOP_BIT_FOUND;
    CMPB #0;
    BEQ check_bit_found;Check if stop bit is found or not
    ;Here we know the stop bit is found and we polled for 1000times.
    ;Start evaluation of the poll we completed. Confidence Intervals could be theoretically larger for even more confidence but not necessary.
    LDD HIGHS;
    CPD CONF_STOP;
    BLO continueChecking;
    LDAB 0b11100100;
    ANDB EVAL_BYTE;
    STAB EVAL_BYTE;
    RTS;
    continueChecking:
    ; for 880 c=0 means bigger or same than it.
    ; for 921 c=0 means bigger or same than it. => c=1 needs to be fulfilled for the interval to be correct.
    ; So only c=0 and c=1 is correct. c=1 and c=0 is impossible; So C=0 XOR C=1 means in the interval
    LDD HIGHS;
    CPD CONF_IO_UPPER;
    ;Transfer CCR to X for temporary Storage.
    TFR CCR,X;
    CPD CONF_IO_LOWER;
    ;Transfer the CCR to A first as Operations can affect status Bits.
    TPA;
    ;Transfer the CCR from the first operation to the B register
    TFR X,B;
    ;Bit we are interested in is in A0
    EORA B;
    ;Isolate Bit A0
    ANDA #$01;
    ;Check if we found a confidence Interval
    CMPA #$01;
    ;Did not find the Interval.
    BNE continueChecking2;
    ;Found the Interval. Set Eval Byte accordingly;
    LDAB 0b11100010;
    ANDB EVAL_BYTE;
    STAB EVAL_BYTE;
    continueChecking2:
    LDD HIGHS;
    CPD CONF_IO_UPPER;
    TFR CCR,X;
    CPD CONF_IO_LOWER; 
    TPA;
    TFR X,B;
    EORA B;
    ANDA #$01;
    LDAB EVAL_BYTE;
    ;Reset any bits that may still be set incorrectly
    ANDB #$E0;
    ;Set the last bit of the status Bit if A0 is set.
    EORB A;
    ;Stab the Eval Byte. This is gonna be a nightmare.
    STAB EVAL_BYTE;
    RTS;

    check_bit_found:


    RTS



    continue_polling:
    BRCLR PTH_PTH0,continue;
    addHigh:
    LDD HIGHS;
    INC;
    STD HIGHS;
    continue:
    LDD TOTAL_POLLS;
    INC;
    STD TOTAL_POLLS;
    RTS;
