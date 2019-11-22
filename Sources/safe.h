/* safe.h */
#ifndef _SAFE_H_
#define _SAFE_H_

/* Here we list the functions */

void getButtonPress(void); // 1 byte for Input parameter
void init(void);
void DATWRT4(unsigned char);
void delay10ms(void);
void LCD_INIT(void);
// value: Parameter passing scheme: 1 byte: Register B, so 'value' will be in Register B      
/* function that adds the parameter value (on B) to global CData */
/* and then stores the result in ASMData */
/* variable which receives the result of AddVar */

/* External declaration of variables */
/* Here we list the variables that can be accessed by the .c file. These variables are usually
   the output of functions*/
extern unsigned char ButtonPressed;// This variable/constant defined in the ASM file will be accessible in the .c file

#endif /* _SAFE_H_ */