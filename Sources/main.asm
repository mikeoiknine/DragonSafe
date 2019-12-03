;**************************************************************
;* This stationery serves as the framework for a              *
;* user application. For a more comprehensive program that    *
;* demonstrates the more advanced functionality of this       *
;* processor, please see the demonstration applications       *
;* located in the examples subdirectory of the                *
;* Freescale CodeWarrior for the HC12 Program directory       *
;**************************************************************

; export symbols
            XDEF init
            XDEF getButtonPress
            XDEF DATWRT4
            XDEF delay10ms
            XDEF ButtonPressed
            XDEF LCD_INIT
            
            XDEF LCD_CLEAR
           
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on

; Include derivative-specific definitions 
	INCLUDE 'mc9s12dp256.inc' 		

		    
; variable/data section
MY_EXTENDED_RAM: SECTION
; Insert here your data definition. For demonstration, temp_byte is used.
R1_LCD      EQU     $1001
R2_LCD      EQU     $1002
R3_LCD      EQU     $1003
TEMP        EQU     $1200
	
LCD_DATA	EQU PORTK		
LCD_CTRL	EQU PORTK		
RS	EQU mPORTK_BIT0	
EN	EQU mPORTK_BIT1

ButtonPressed: DS.B 1	


; code section
MyCode:     SECTION
; this assembly routine is called by the C/C++ application
init:       ldaa #$00
            staa DDRA   
            movb  #$FF, DDRK  ; Set Portk to output
            jsr LCD_INIT  
            rts               ; return to caller


 getButtonPress:  ldaa PORTA
                  clrb 
                  cba
                  nop
                  nop
                  nop
                  nop
                  beq getButtonPress
                  staa ButtonPressed
                  rts
      
      
LCD_INIT:   LDAA  #$33
		        JSR	  COMWRT4    	
  		      JSR   DELAY1MS
  		      LDAA  #$32
		        JSR	  COMWRT4		
 		        JSR   DELAY1MS
		        LDAA	#$28	
		        JSR	  COMWRT4    	
		        JSR	  DELAY1MS   		
		        LDAA	#$0E     	
		        JSR	  COMWRT4		
		        JSR   DELAY1MS
		        LDAA	#$01     	
		        JSR	  COMWRT4    	
      		  JSR   DELAY1MS
      		  LDAA	#$06     	
      		  JSR	  COMWRT4    	
      		  JSR   DELAY1MS
      		  LDAA	#$80     	
      		  JSR	  COMWRT4    	
      		  JSR   DELAY1MS
      		  rts


COMWRT4:               		
		  STAA	TEMP		
		  ANDA  #$F0
		  LSRA
		  LSRA
		  STAA  LCD_DATA
		  BCLR  LCD_CTRL,RS 	
		  BSET  LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR  LCD_CTRL,EN 	
		  LDAA  TEMP
		  ANDA  #$0F
    	LSLA
    	LSLA
  		STAA  LCD_DATA
		  BCLR  LCD_CTRL,RS 	
		  BSET  LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR  LCD_CTRL,EN 	
		  RTS
		  
		  
LCD_CLEAR:
      TBA
      JSR COMWRT4
      JSR DELAY1MS
      rts
		  
		  
DATWRT4: 
      JSR   DELAY1MS                  	
		  STAB	 TEMP		
		  ANDB   #$F0
		  LSRB
		  LSRB
		  STAB   LCD_DATA
		  BSET   LCD_CTRL,RS 	
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  LDAB   TEMP
		  ANDB   #$0F
    	LSLB
      LSLB
  		STAB   LCD_DATA
  		BSET   LCD_CTRL,RS
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  RTS
		  
delay10ms: ldx #$000A
loop:      jsr DELAY1MS
           dbne X, loop
           rts
           
           
           	  
;-------------------		  
; 1 msec delay. The Serial Monitor works at speed of 48MHz with XTAL=8MHz on Dragon12+ board
; Freq. for Instruction Clock Cycle is 24MHz (1/2 of 48Mhz). 
; (1/24MHz) x 10 Clk x240x100=1 msec. Overheads are excluded in this calculation.
DELAY1MS

        PSHA		;Save Reg A on Stack
        LDAA    #1		  
        STAA    R3_LCD		
         
L3      LDAA    #100
        STAA    R2_LCD
L2      LDAA    #240
        STAA    R1_LCD
L1      NOP         ;1 Intruction Clk Cycle
        NOP         ;1
        NOP         ;1
        DEC     R1_LCD  ;4
        BNE     L1  ;3
        DEC     R2_LCD  ;Total Instr.Clk=10
        BNE     L2
        DEC     R3_LCD
        BNE     L3       
        PULA			;Restore Reg A
        RTS
;-------------------
