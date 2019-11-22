#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
//#include "mc9s12dp256.h"
#include "main_asm.h" /* interface to the assembly module */
#include "safe.h"

//extern init(void);
//extern getButtonPress(void);

void main(void) { // in Assembly code, this is treated as a SubRoutine
  unsigned int a = 0;
  int success = 1;
  int i;
  unsigned char success_code[4]  = {'4', '1', '1', '1'};
  unsigned char user_input[4] ;
  unsigned char char_to_print;
  EnableInterrupts;
  //__asm("staa FF");
  init();
  
///  setB();
  while(a < 4) {
    getButtonPress();
    
    switch(ButtonPressed) {
      case 0x01: char_to_print = '1'; break;
      case 0x02: char_to_print = '2'; break;
      case 0x04: char_to_print = '3'; break;
      case 0x08: char_to_print = '4'; break;
      case 0x10: char_to_print = '5'; break;
      case 0x20: char_to_print = '6'; break;
      case 0x40: char_to_print = '7'; break;
      case 0x80: char_to_print = '8'; break;
      default:  char_to_print = 'E'; 
    }
    
    user_input[a] = char_to_print;
    DATWRT4(char_to_print);
    a++;
    
    delay10ms();
    delay10ms();
  }
  
  // LCD_INIT(); <- Flashes board :O
  delay10ms();
  
  for (i = 0; i < 4; i++) {
   if (user_input[i] != success_code[i]) {
      success = 0;
      break;
   }
  }
  
  if (success == 0) {
      DATWRT4('W');
      DATWRT4('R');
      DATWRT4('O');
      DATWRT4('N');
      DATWRT4('G');
      DATWRT4('!');
  }
  
  if (success == 1) {
      /* TODO: Move servo */
      DATWRT4('S');
      DATWRT4('U');
      DATWRT4('C');
      DATWRT4('C');
      DATWRT4('E');
      DATWRT4('S');
      DATWRT4('S');
      DATWRT4('!');
  }
  
 
  
     
  for (;;) { 
    _FEED_COP();
  }
}
