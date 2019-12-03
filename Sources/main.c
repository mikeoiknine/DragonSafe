#include <hidef.h>      /* common defines and macros */
#include "derivative.h" /* derivative-specific definitions */
#include "main_asm.h"   /* interface to the assembly module */
#include "safe.h"

unsigned char count;
unsigned char n;
int timed_out;
unsigned char user_input[4];
int i_x;

void out_of_time(void);
char *getUserInput();
void write_to_lcd(char* text);

void interrupt toi_isr(void) {
  n++;

  // Wait about 5s
  if (n >= 23) {
    n = 0;
    PORTB = 0xff;
    out_of_time();
    PORTB = 0x00;

    // Stop the timer
    TSCR1 &= 0x7F;
    TSCR2 &= 0x7F;

    i_x = 0;
    memset(&user_input[0], 0, 4);

  } else {
    TFLG2 = 0x80;
  }
}


#pragma CODE_SEG DEFAULT
typedef void (*near tIsrFunc)(void);
const tIsrFunc _vect[] @0xFFDE = {
  toi_isr
};



void main(void) {
  int success = 0, i = 0;

  char success_msg[] = "Success!";
  char failure_msg[] = "Wrong!";

  unsigned char success_code[4]  = {'1', '1', '1', '1'};
  //unsigned char user_input[4];

  DDRB = 0xFF;
  count = 0;
  n = 0;
  timed_out = 0;

  // Set up PWM for motor
  PWMPRCLK = 0x04;  // Clock A = 1.5MHz
  PWMSCLA = 125;    // ClockSA = 6000Hz
  PWMCLK = 0x10;
  PWMPOL = 0x10;
  PWMCAE = 0x0;
  PWMCTL = 0x0;
  PWMPER4 = 120;   // PWM_Freq = 6000Hz / 120 = 50Hz
  PWMDTY4 = 5;     // 7% Duty Cycle
  PWMCNT4 = 10;
  PWME = 0x10;
  EnableInterrupts;

  delay10ms();
  init();

  while(success == 0) {
    success = 1;

    memset(&user_input[0], 0, 4);
    delay10ms();

    getUserInput(user_input);
    delay10ms();
    delay10ms();

    // Check if the user inputed the correct code
    for (i = 0; i < 4; i++) {
      if (user_input[i] != success_code[i]) {
        success = 0;
        break;
      }
    }

    if (success == 1) {
      break;
    }

    // DisableInterrupts;
    // Stop the timer
    TSCR1 &= 0x7F;
    TSCR2 &= 0x7F;

    write_to_lcd(failure_msg);
  }


  //DisableInterrupts;
  // Stop the timer
  TSCR1 &= 0x7F;
  TSCR2 &= 0x7F;

  PWMDTY4 = 8;     // 7% Duty Cycle
  PWMCNT4 = 10;
  PWME = 0x10;

  write_to_lcd(success_msg);
  return;
}

char *getUserInput(char *user_input) {
  unsigned char char_to_print;
  //int i_x;

  for (i_x = 0; i_x < 4; i_x++) {
    getButtonPress();

    // Start the timer on the first input
    if (i_x == 0) {
      TSCR1 = 0x80; // Turn timer on
      TSCR2 = 0x86; // Enable timer interrupt & pre-scale to 128
      TFLG2 = 0x80; // Clear timer interrupt flag
    }

    // Reset timer on user input
    n = 0;

    // Print Character to screen
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

    user_input[i_x] = char_to_print;
    DATWRT4(char_to_print);

    // Debounce user input
    delay10ms();
    delay10ms();
  }

  return user_input;
}


void out_of_time(void) {
  char time_out_msg[] = "Out of Time!";
  write_to_lcd(time_out_msg);
}

void write_to_lcd(char* text) {
  int i;
  LCD_CLEAR(0x01);
  for (i = 0; i < strlen(text); i++) {
      DATWRT4(text[i]);
  }

  for(i = 0; i < 20; i++) {
    delay10ms();
  }

  LCD_CLEAR(0x01);
}
