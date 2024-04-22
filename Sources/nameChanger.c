



unsigned char FRAMECOUNT = 0;
unsigned char ACTIVE_NAME = 0;
unsigned char FRAME_BUFFER[16] = {0};

const unsigned short MAGIC_NUMBER_PWMPER_1 = 0xCB73;
const unsigned short MAGIC_NUMBER_PWMPER_2 = 0xF424;
const unsigned short MAGIC_NUMBER_PWMDTY_1 = 0x43D1;
const unsigned short MAGIC_NUMBER_PWMDTY_2 = 0x30D4;

const char NAME_1[]  = "Julian Warttmann © IT WS2021/2022";
const char NAME_2[]  = "Nikolai Glock © IT WS2021/2022";

void displayNames(void){
    if(FRAME_BUFFER >=17)return;
    FRAMECOUNT++;
    unsigned char buffer[16] = ACTIVE_NAME ? NAME_1[FRAMECOUNT] : NAME_2[FRAMECOUNT];  
    
}