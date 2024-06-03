


   XREF PTH
   XDEF signalDecoderControl,init_intervals


.data: SECTION
HIGHS: DC.B 1
TOTAL_POLLS: DC.B 1
;0 if false 1 if true
STOP_BIT_FOUND: DC.B 1
WAIT_FOR_DATA: DC.B 1
DATA_BUFFER: DC.W 1

DATA_STREAM: DS.B 8;
STREAM_POSITION: DC.B 1;

VALID_MINUTES: DC.B 1;
VALID_HOURS: DC.B 1

TEMP: DC.B 1;

;Confidence Intervals
CONF_STOP: DS.B 1 ; 191+ 0xBF
CONF_I0: DS.B 2 ; [189,171] , [0xBD,0xAB]
CONF_I1: DS.B 2 ; [169,151] , [0xA9,0x97]

.const: SECTION
  
  


.init: SECTION
    init_intervals:
    ;191
    MOVB #$BF,CONF_STOP;
    ;[189,171]
    MOVW #$BDAB,CONF_I0;
    ;[169,151]
    MOVW #$A997,CONF_I1;
    
    MOVW #$0000,DATA_BUFFER;
    RTS;
    
    validOne:
    LDAB #$00;
    JSR putBit;
    
    validZero:
    LDAB #$01;
    JSR putBit;
    
    signalDecoderControl:
    ;If the Number of Total Polls is less than 200, we need to continue polling. 
    JSR pollSignal;
    
    LDAB STOP_BIT_FOUND;
    CMPB #$00;
    BEQ checkForStopBit;
    
    LDAB WAIT_FOR_DATA;
    CMPB #$01;
    BEQ checkDataBuffer;
    
    LDAB TOTAL_POLLS;
    CMPB #200;
    BEQ evalWindow;
    RTI;
    
    evalWindow:
    LDAB HIGHS;
    ;Check if Highs are outside lowest Count;
    CMPB CONF_I1+1;
    BLT resetToDefault;
    CMPB CONF_I1;
    BLE validOne;
    CMPB CONF_I0+1;
    BLT resetToDefault;
    CMPB CONF_I0;
    BLE validZero;
    CMPB CONF_STOP;
    BLT resetToDefault;
    ;Valid Stop Bit here
    MOVB #$01,WAIT_FOR_DATA;
    JSR evalBits;
    
    resetToDefault:
    MOVB #$00,STOP_BIT_FOUND;
    JSR resetInterval;
    
    pollSignal:
    ;Load the PTH Register to get the bit we are interested in
    LDAA PTH;
    ;Isolate the Bit we want to check;
    ANDA #$01;
    ;Check if bit is set
    CMPA #$01;
    BNE continue;
    addHigh:
    LDAB HIGHS;
    INCB;
    STAB HIGHS;
    continue:
    LDAB TOTAL_POLLS;
    INCB;
    STAB TOTAL_POLLS;
    RTS;
    
    ;Responsible for filling the Data Buffer
    returnFromDecoder:
    LDD DATA_BUFFER;
    XGDX;
    LDAB PTH;
    ANDB #$01;
    ABX;
    XGDX;
    STD DATA_BUFFER;
    RTI;
    
    checkForStopBit:
    LDAB TOTAL_POLLS;
    CMPB #200;
    ;Return if the total number of polls is less than 200;
    BNE returnFromStopBit;
    LDAB HIGHS;
    CMPB CONF_STOP;
    ;Throw away the interval if the confidence threshhold is not met
    BLT resetInterval;
    MOVB #$01,STOP_BIT_FOUND;
    MOVB #$01,WAIT_FOR_DATA;
    MOVW #$0000,DATA_BUFFER;
    returnFromStopBit:
    RTI;
    
    checkDataBuffer:
    LDAB TOTAL_POLLS;
    CMPB #16;
    BLT returnFromDecoder;
    ;Count of 1s in Y
    LDD #$0000;
    XGDY;
    ;Copy of original DATA_BUFFER in X
    LDD DATA_BUFFER;
    XGDX;
    ;Loop that counts all the 1's in the Data Buffer
    count_loop:
    LDD DATA_BUFFER;
    ANDB #01
    CMPB #$00;
    BEQ continueDataBufferCheck;
    ;Increase Count by 1
    INY;
    continueDataBufferCheck:
    XGDX;
    LSRD;
    CPD #$0000;
    BEQ finished_counting;
    TFR D,X;
    BRA count_loop;
    ;Number of Highs from Data Buffer.
    finished_counting:
    XGDY;
    ;If we get 11/16 lows, we can assume, that a Data Bit has started.
    CPD #5;
    BHI startIntervals;
    ;Push out one Bit to the right and continue looking;
    LDD DATA_BUFFER;
    LSLD;
    XGDX;
    LDAB PTH;
    ANDA #$01;
    ABX;
    XGDX;
    STD DATA_BUFFER;
    RTI;
    
    
    
    startIntervals:
    STD HIGHS;
    MOVB #$10,TOTAL_POLLS;
    MOVB #$00,WAIT_FOR_DATA;
    RTI;
    
    
    resetInterval:
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    RTI; 
    
    
    
    putBit:
    STAB TEMP; 
    LDD #8;
    XGDX;
    LDD STREAM_POSITION;
    IDIV;
    LDY #DATA_STREAM
    ABY;
    XGDX;
    ANDA #$00;
    LDAA TEMP;
    shift_loop:
    CMPB #$00;
    BEQ continuePutting;
    LSLA;
    DECB;
    BRA shift_loop;
    
    continuePutting:
    ABA;
    STAA Y;
    BRA resetInterval;
    
    invalidBit:
    JSR resetToDefault;
    
    ;TODO
    evalBits:
    JSR evalMinutes;
    JSR evalHours;
    
    
    evalMinutes:
    LDD DATA_BUFFER+2;
    LSRD;
    LSRD;
    LSRD;
    ;Here we start with BIT 20
    ANDB #$01;
    CMPB #$01;
    BNE invalidBit;
    ;Load Data again
    LDD DATA_BUFFER+2;
    LSRD;
    LSRD;
    LSRD;
    LSRD;
    ;Temp contains the 8 Minute Bits now
    STAB TEMP;
    ;Put 0 into Y,X and D
    LDD #0;
    XGDY;
    LDD #0;
    XGDX;
    LDD #0;
    
    LDAA TEMP;
    LDAB TEMP;
    ;Isolate first bit and add to X; If X is even, 0 bit not set => even;
    ;0
    ANDB #$01;
    ABX;
    TAB;
    LSRB;
    ;1
    ANDB #$01;
    ABX;
    LSRA;
    TAB;
    LSRB;
    ;2
    ANDB #$01;
    ABX;
    LSRA;
    TAB;
    LSRB;
    ;3
    ANDB #$01;
    ABX;
    LSRA;
    TAB;
    LSRB;
    ;4
    ANDB #$01;
    ABX;
    TAB;
    LSRA;
    LSRB;
    ;5
    ANDB #$01;
    ABX;
    TAB;
    LSRB;
    ;6
    ANDB #$01;
    ABX;
    LSRA;
    TAB;
    LSRB;
    ; Check if Parity Bit is even or ODD;
    CMPB #$00;
    BEQ parity_even_min;
    BRA parity_odd_min;
    
    parity_even_min:
    XGDX;
    CMPB #$00;
    BEQ validBit;
    CMPB #$04;
    BEQ validBit;
    JSR invalidBit;
    
    parity_odd_min:
    XGDX;
    CMPB #$03;
    BEQ validBit;
    CMPB #$07;
    BEQ validBit;
    JSR invalidBit;
    
    
    validBit:
    LDD DATA_BUFFER+2;
    LSRD;
    LSRD;
    LSRD;
    LSRD;
    STAB VALID_MINUTES;
    
    
    evalHours:
    ;Load Byte 25-40
    LDD #0;
    XGDX;
    LDD DATA_BUFFER+3
    LSRD;
    LSRD;
    LSRD;
    LSRD;
    ;Isolate the first 7 bits in B to get the Hours+Parity
    ANDB #$7F;
    TBA;
    ;Isolate first bit and add to X; If X is even, 0 bit not set => even;
    ;0
    ANDB #$01;
    ABX;
    TAB;
    LSRB;
    ;1
    ANDB #$01;
    ABX;
    LSRA;
    TAB;
    LSRB;
    ;2
    ANDB #$01;
    ABX;
    LSRA;
    TAB;
    LSRB;
    ;3
    ANDB #$01;
    ABX;
    LSRA;
    TAB;
    LSRB;
    ;4
    ANDB #$01;
    ABX;
    TAB;
    LSRA;
    LSRB;
    ;5
    ANDB #$01;
    ABX;
    TAB;
    LSRB;
    CMPB #$00;
    BEQ parity_even_hours;
    BRA parity_odd_hours;
     
    parity_even_hours:
    XGDX;
    CMPB #$00;
    BEQ validBitH;
    CMPB #$04;
    BEQ validBitH;
    JSR invalidBit;
    
    parity_odd_hours:
    XGDX;
    CMPB #$03;
    BEQ validBitH;
    CMPB #$07;
    BEQ validBitH;
    JSR invalidBit;
    
    
    validBitH:
    LDD DATA_BUFFER+3;
    LSRD;
    LSRD;
    LSRD;
    LSRD;
    ANDB #$7F;
    STAB VALID_HOURS;
    RTS;
    
    
    
    
    
    
    
     
    
    
    
    
    
    
    
    
    