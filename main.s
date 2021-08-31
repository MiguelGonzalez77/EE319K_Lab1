;****************** main.s ***************
; Program initially written by: Yerraballi and Valvano
; Author: Miguel Gonzalez
; Professor: Yerraballi
; UTEID: mag9688
; Date Created: 1/15/2018 
; Last Modified: 1/17/2021 
; Brief description of the program: Solution to Lab1
; The objective of this system is to implement odd-bit counting system
; Hardware connections: 
;  Output is positive logic, 1 turns on the LED, 0 turns off the LED
;  Inputs are negative logic, meaning switch not pressed is 1, pressed is 0
;    PE0 is an input 
;    PE1 is an input 
;    PE2 is an input 
;    PE4 is the output
; Overall goal: 
;   Make the output 1 if there is an even number of switches pressed, 
;     otherwise make the output 0

; The specific operation of this system 
;   Initialize Port E to make PE0,PE1,PE2 inputs and PE4 an output
;   Over and over, read the inputs, calculate the result and set the output
; PE2  PE1 PE0  | PE4
; 0    0    0   |  0    3 switches pressed, odd 
; 0    0    1   |  1    2 switches pressed, even
; 0    1    0   |  1    2 switches pressed, even
; 0    1    1   |  0    1 switch pressed, odd
; 1    0    0   |  1    2 switches pressed, even
; 1    0    1   |  0    1 switch pressed, odd
; 1    1    0   |  0    1 switch pressed, odd
; 1    1    1   |  1    no switches pressed, even
;There are 8 valid output values for Port E: 0x00,0x11,0x12,0x03,0x14,0x05,0x06, and 0x17. 

; NOTE: Do not use any conditional branches in your solution. 
;       We want you to think of the solution in terms of logical and shift operations

GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_DEN_R   EQU 0x4002451C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

       THUMB
       AREA    DATA, ALIGN=2
;global variables go here
      ALIGN
      AREA    |.text|, CODE, READONLY, ALIGN=2
      EXPORT  Start
Start
     ;code to run once that initializes PE4,PE2,PE1,PE0
	 ;Initialization:
	 ;Step 1: Turn on the clock
	 
	 LDR R0, =SYSCTL_RCGCGPIO_R ;R0 points to Clock 
	 LDRB R1, [R0] ;Read SYSCTL_RCGCGPIO_R into R1
	 ORR R1,#0x10 ;modify, this will cause port E to have bit 1 to turn on Port E clock
	 STRB R1, [R0] ;write back to SYSCTL_RCGCGPIO_R
	 
	 ;Step 2: Wait for the clock to stabilize
	 
	 NOP ;No OP filler to allow clock to stabilize
	 NOP
	 
	 ;Step 3: Define inputs and outputs 
	 
	 LDR R0, =GPIO_PORTE_DIR_R ;R0 points to memory address of directory
	 LDRB R1, [R0] ; Read GPIO_PORTE_DIR_R to R1 focusing only on 8 bits
	 AND R1, #0xF8 ; ANDs the bits to make pins 0, 1, and 2 to be 0 
	 ORR R1, #0x10 ; ORRs the bits to make pin 4 be 1 while leaving the rest of the bits unchanged.
	 STRB R1, [R0] ; write back to GPIO_PORTE_DIR_R with 8 bits
	 
	 ;Step 4: Digitally enable pins PE0, PE1, PE2, and PE4
	 
	 LDR R0, =GPIO_PORTE_DEN_R ;R0 points to GPIO_DEN
	 LDRB R1, [R0] ;read GPIO_PORTE_DEN_R to R1 focusing on the first 8 bits
	 ORR R1, #0x17 ;ORR to set bits 0, 1, 2, and 4 equal to 1 allowing the pins to be enabled.
	 STRB R1, [R0] ;write back to GPIO_PORTE_DEN_R with 8 bits
loop
      ;code that runs over and over
	 LDR R0, =GPIO_PORTE_DATA_R ;R0 = 0x400243FC
	 LDRB R0, [R0] ;Read port E to register R0
     AND R1, R0, #0x01 ;mask, R1 == 0
	 AND R2, R0, #0x02 ;mask, select PE1
     LSR R2, #1 ;shift R2 to bit 1
     AND R3, R0, #0x04 ; mask, select PE2
	 LSR R3, #2 ;shift R3 to bit 0
     EOR R1, R1, R2 ;exclusive OR  for R1 and R2 setting it to R1 meaning even number of switches unpressed
     EOR R1, R1, R3 ; exclusive OR for R1 and R3 setting it to R1 meaning odd number of switches unpressed
     LSL R1, #4; shift R1 to bit 4 to result to PE4
	  
     LDR R0, =GPIO_PORTE_DATA_R ; read R0 with refined Port E data
     STRB R1, [R0] ;write Port E, sets PE4 result to LED
   B    loop ; go back to load Port E data
	
    
     ALIGN        ; make sure the end of this section is aligned
     END          ; end of file   

