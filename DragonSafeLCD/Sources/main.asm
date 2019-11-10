;****************************************************************
;*
;* UTEP EE3376
;* string2lcd_hcs12.asm
;* Dragon12/HCS12 board, Code Warrior v3
;* 20 June 2005
;*
;* This code demonstrates the basic initialization and use
;* of a Hantronix LCD (Model HDM16216L-5) on the Dragon12 HCS12 board.
;* This is a 16 char x 2 line LCD with a 5x7 dots character format.
;* Uses a HD44780 based controller. The Dragon12 LCD is hardwired to use
;* a 4-bit interface to Port K with pins set up as follows:
;*
;* RS = PK0 (Port K bit 0 to RS Register Selector)
;*   -> RS = 0 selects Instruction Register, RS=1 selects Data Register
;* EN = PK1 (Enable; pulse enable to latch data-write into LCD)
;* R/W = connected to ground (W = 0 since we only write)
;* DB4 = PK2; DB5 = PK3; DB6 = PK4; DB7 = PK5
;* PK6 and PK7 are unused
;*
;* The program is based on using strings to write to each line of the LCD.
;* The final display will show string1 'Code Warrior' on line 1
;* and string2 'Dragon12' on line 2. You can modify the strings manually
;* in the program itself or in DBug12 using the 'mm' command.
;*
;****************************************************************
 
; export symbols
            XDEF asm_main            ; export 'Entry' symbol
            ;ABSENTRY asm_main        ; for absolute assembly: mark this as application entry point
 
 
PSEUDO_ROM       EQU       $1000     ; absolute address to place code/constant data
RAM                      EQU       $1400     ; absolute address to place variables
STACK         EQU       $3C00     ; top of stack
 
portk             EQU       $32       ;
portk_ddr     EQU       $33       ; data direction register for Port K
 
enable_mask   EQU       %00000010 ; enable bit for enable on/off pulses
output        EQU       %11111111 ; make a port an output
 
msec          EQU       $1770     ; 6000 (=$1770) loops = 1 msec in startx loop
 
; LCD initialization strings; msb = most significant bits, lsb = least sig. bits
init_lcd1     EQU       $0C       ; first init string we write (3 times) to LCD  on startup
init_lcd2     EQU       $08       ; set to 4 bit transfer (repeat twice)
init_lcd3     EQU       $08       ; set to 2 lines, 5x7 dots, 4 msb of 8 bits
init_lcd4     EQU       $20       ; set to 2 lines, 5x7 dots, 4 lsb of 8 bits        
init_lcd5     EQU       $00       ; display off, 4 msb
init_lcd6     EQU       $20       ; display off, 4 lsb
init_lcd7     EQU       $00       ; display clear, 4 msb
init_lcd8     EQU       $04       ; display clear, 4 lsb
init_lcd9     EQU       $00       ; entry mode 4 msb
init_lcd10   EQU       $18       ; entry mode, 4 lsb (increment DDRAM, cursor moves)
init_lcd11   EQU       $00       ; display on, 4 msb
init_lcd12   EQU       $3C       ; display on, 4 lsb (display on, cursor on, blink on)
init_lcd13   EQU       $30       ; display on, 4 lsb (display on, cursor/blink off)
        
;-----------------------------------------------------
; variable/data section
            ORG RAM
; Insert your data definitions here.
 
string1:      dc.b    "Code Warrior" ; length of 12
string2:      dc.b    "Dragon12"     ; length of 8
 
;------------------------------------------------------
; code section
              ORG    PSEUDO_ROM    ;set PC to $1000
 
asm_main:
            ; do some initialization
              lds       #STACK              ; initialize stack pointer
              movb      #output, portk_ddr  ; make Port K an Output
              jsr       LCD_INIT            ; initialize the LCD
                
                
            ; write string1 to the LCD line 1
              ldx       #string1            ; pointer to string passed via reg X
              ldab      #$0C                ; load length into register B
              jsr       WRITE_STRING
                
            ; set LCD to line 2 at DDRAM address $40, RS=0
              ldaa      #$30               ; RS=0, %1100 to DB7-DB4
              jsr       WRITE_NIBBLE
              ldaa      #$00                 ; RS=0, %0000 to DB3-DB0
              jsr       WRITE_NIBBLE
                
              ; write string2 to the LCD line 2
              ldx       #string2            ; pointer to string passed via reg X
              ldab      #$08                ; load
              jsr       WRITE_STRING
                
             ; display on, cursor off, blink off; 2 4-bit writes needed
              ldaa      #init_lcd11
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
 
              ldaa      #init_lcd13
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
                  
              swi        ; end the program
                            
;------------------------------------------------------
; Subroutine LCD_INIT to initialize the LCD
; sets LCD to line 1
 
LCD_INIT:    
              ; write init byte three times to power-up
              ldd       #$14        ; wait 20 msec after power on  (need delay > 15 msec)
              jsr       DELAY
                  
              ; write first init string three times with various delays
              ldaa      #init_lcd1
                  
              ; write 1/delay 1
              jsr       WRITE_NIBBLE    ; pulse data in portk to write it
              ldd       #$05                ; wait 5 msec (need delay > 4.1 msec)
              jsr       DELAY
                  
              ; write 2/delay 2
              jsr       WRITE_NIBBLE    ; pulse data in portk to write it
              ldd       #$01                ; wait 1 msec (need delay > 100 usec)
              jsr       DELAY
                  
              ; write 3, no delay needed
              jsr       WRITE_NIBBLE    ; no delay needed here
                  
              ; *********************************************************
              ; Configuration for the LCD here
              ; *********************************************************
              ; set to 4 bit transfers; only one 4-bit write needed
              ldaa      #init_lcd2
              jsr       WRITE_NIBBLE    
              ldd       #$01
              jsr       DELAY
                  
              ; set to 2 lines, 5x7 dot character display; 2 4-bit writes needed
              ldaa      #init_lcd3
              jsr       WRITE_NIBBLE    
              ldd       #$01
              jsr       DELAY
 
              ldaa      #init_lcd4
              jsr       WRITE_NIBBLE    
              ldd       #$01
              jsr       DELAY
                  
              ; display off;
              ldaa      #init_lcd5
              jsr       WRITE_NIBBLE    
              ldd       #$01
              jsr       DELAY
 
              ldaa      #init_lcd6
              jsr       WRITE_NIBBLE    
              ldd       #$01
              jsr       DELAY
                  
              ; display clear;
              ldaa      #init_lcd7
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
 
              ldaa      #init_lcd8
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
                  
              ; entry mode = increment, cursor move; 2 4-bit writes needed
              ldaa      #init_lcd9
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
 
              ldaa      #init_lcd10
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
                  
              ; display on, cursor on, blink on; 2 4-bit writes needed
              ldaa      #init_lcd11
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
 
              ldaa      #init_lcd12
              jsr       WRITE_NIBBLE
              ldd       #$01
              jsr       DELAY
                  
              rts
 
;------------------------------------------------------
; Subroutine WRITE_STRING will write string to current line of LCD
; pass string pointer via reg X
 
WRITE_STRING:
 
begin:    psha
              pshb
              pshx
 
loop:      ldaa      0,x       ; 4 msb nibble
              lsra                ; center msb nibble
              lsra
              oraa       #$01      ; set RS=1
              anda      #$3D      ; clear upper 2 bits and enable bit
              jsr       WRITE_NIBBLE
              ldaa      0,x       ; 4 lsb nibble
              lsla       ; shift it to the left
              lsla
              oraa       #$01      ; set RS=1
              anda      #$3D      ; clear upper 2 bits and enable bit
              jsr       WRITE_NIBBLE
              inx
              decb                ; continue for length
              bne       loop
            
              pulx
              pulb
              pula                        
              rts
                
;------------------------------------------------------
; Subroutine WRITE_NIBBLE
; Used each time a write occurs; portk holds write data
; Need enable high to latch the write data, then low to clear way for next write
; Need to wait at least 40 usec after enable for function to complete - we
; build this delay into this subroutine
;
; Data is transfered in the A register and must be formatted with data
; in bit 5 to bit 2, the RS bit is bit 0, bit 6 and 7 are unused and set
; to zero and bit 1 being pulsed in the subroutine and should be cleared
; initially.
 
; example calling sequence of sending A
; ldaa  #$0A
; lsla
; lsla
; ora   #$02
; anda  #$3D
; JSR   WRITE_NIBBLE
 
WRITE_NIBBLE:
 
            ; save A and B on stack since we need them
              psha
              pshb
                
              staa portk
 
              ; pulse the enable
              bset    portk, enable_mask    
              nop
              nop
              bclr    portk, enable_mask
                
              ldd #$01
              jsr DELAY
                
              pulb
              pula
                
              rts                
                            
;------------------------------------------------------
; Subroutine DELAY - Delay = (D) * msec
; where Register D contains number of x (startx) loops
; and there is a 1 msec delay per x loop
; Add push/pull instructions to protect D, X and Y
DELAY:
              pshd
              pshx
              pshy
        
              tfr       D,Y     ; (D) -> (Y)
starty:    ldx       #msec   ; start y loop and set x loop to 1 msec
startx:    dex                ; start x loop - 4 cycles per startx loop if branch
              bne       startx    
              dey        
              bne       starty
        
              puly
              pulx
              puld
              
              rts    
                
;****************************************************************