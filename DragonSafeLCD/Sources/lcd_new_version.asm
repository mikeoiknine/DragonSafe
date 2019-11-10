;Displaying "YES" on LCD for Dragon12+ Trainer Board 
;with HCS12 Serial Monitor Program installed. This code is for CodeWarrior IDE
;Modified by Mazidi from Chapter 12 of HS12 book by Mazidi & Causey
;On Dragon12+ LCD data pins of D7-D4 are connected to Pk5-Pk2, En=Pk1,and RS=Pk0,




        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
    
; Include derivative-specific definitions 
		  INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
	
LCD_DATA	EQU PORTK		
LCD_CTRL	EQU PORTK		
RS	EQU mPORTK_BIT0	
EN	EQU mPORTK_BIT1	

;----------------------USE $1000-$2FFF for Scratch Pad 
R1      EQU     $1001
R2      EQU     $1002
R3      EQU     $1003
TEMP    EQU     $1200

;code section
      ORG   $4000     ;Flash ROM address for Dragon12+
Entry:
	    LDS   #$4000    ;Stack
      
  		LDAA  #$FF
		  STAA  DDRK		
		  LDAA  #$33
		  JSR	  COMWRT4    	
  		JSR   DELAY
  		LDAA  #$32
		  JSR	  COMWRT4		
 		  JSR   DELAY
		  LDAA	#$28	
		  JSR	  COMWRT4    	
		  JSR	  DELAY   		
		  LDAA	#$0E     	
		  JSR	  COMWRT4		
		  JSR   DELAY
		  LDAA	#$01     	
		  JSR	  COMWRT4    	
		  JSR   DELAY
		  LDAA	#$06     	
		  JSR	  COMWRT4    	
		  JSR   DELAY
		  LDAA	#$80     	
		  JSR	  COMWRT4    	
		  JSR   DELAY
		  LDAA	#'Y'     	
		  JSR	  DATWRT4    	
		  JSR   DELAY
		  LDAA  #'E'     	
		  JSR	  DATWRT4 
		  JSR   DELAY
		  LDAA  #'S'     	
		  JSR	  DATWRT4 
		  JSR   DELAY
		   	
AGAIN: BRA	AGAIN      	
;----------------------------
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
;--------------		  
DATWRT4:                   	
		  STAA	 TEMP		
		  ANDA   #$F0
		  LSRA
		  LSRA
		  STAA   LCD_DATA
		  BSET   LCD_CTRL,RS 	
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  LDAA   TEMP
		  ANDA   #$0F
    	LSLA
      LSLA
  		STAA   LCD_DATA
  		BSET   LCD_CTRL,RS
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  RTS
;-------------------		  

DELAY

        PSHA		;Save Reg A on Stack
        LDAA    #1		  
        STAA    R3		
;-- 1 msec delay. The Serial Monitor works at speed of 48MHz with XTAL=8MHz on Dragon12+ board
;Freq. for Instruction Clock Cycle is 24MHz (1/2 of 48Mhz). 
;(1/24MHz) x 10 Clk x240x100=1 msec. Overheads are excluded in this calculation.         
L3      LDAA    #100
        STAA    R2
L2      LDAA    #240
        STAA    R1
L1      NOP         ;1 Intruction Clk Cycle
        NOP         ;1
        NOP         ;1
        DEC     R1  ;4
        BNE     L1  ;3
        DEC     R2  ;Total Instr.Clk=10
        BNE     L2
        DEC     R3
        BNE     L3
;--------------        
        PULA			;Restore Reg A
        RTS
;-------------------



            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
      ORG   $FFFE
      DC.W  Entry     ;Reset Vector. CPU wakes here and it is sent to start of the code at $4000