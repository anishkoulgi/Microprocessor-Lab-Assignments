.MODEL TINY					;setting model to small
.286						;setting stack size
ORG 100H					;assembler directive for setting beginning of code segment

CODE SEGMENT					;code segment begins
     ASSUME CS:CODE,DS:CODE,ES:CODE		;setting logical name to segments
        OLD_IP DW 00				;to store the location of the original address of the interrupt vector cs and ip
        OLD_CS DW 00
JMP INIT					;jump to initialisation section

MY_TSR:
        PUSH AX					;push all registers into stack
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH ES

        MOV AX,0B800H    			;Address of Video RAM
        MOV ES,AX				;setting es to the beginning of display ram
        MOV DI,1200				;setting offset to use in display ram , it gives position along x-axis of the clock,refer note 1

        MOV AH,02H   				;To Get System Clock ...... function 2,interrupt 1Ah
        INT 1AH    				;CH=Hrs, CL=Mins,DH=Sec    
        					;Get the time from bios chip .... stored in bcd format
        
        MOV BX,CX				;mov hrs to bh and minutes to bl
        
        ;.DISPLAYING-HOURS

        MOV CL,2				;counter
        
LOOP1:  ROL BH,4				;converting BCD TO ASCII and printing hrs(2 digits)
        MOV AL,BH
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H				;refer note; static white on blue
        MOV ES:[DI],AX				;moving ax to es+di...di is offset (usually default is ds)
        INC DI					;incrementing twice cause a digit is stored as 2 mem locations for video ram .... refer note
        INC DI
        DEC CL
        JNZ LOOP1

        MOV AL,':'				
        MOV AH,97H				;refer note; blinking white on blue
        MOV ES:[DI],AX
        INC DI
        INC DI

	;.DISPLAYING-MINUTES

        MOV CL,2
        
LOOP2:  ROL BL,4
        MOV AL,BL
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC CL
        JNZ LOOP2

        MOV AL,':'
        MOV AH,97H
        MOV ES:[DI],AX

        INC DI
        INC DI

	;.DISPLAYING-SECONDS

        MOV CL,2
        MOV BL,DH

LOOP3:  ROL BL,4
        MOV AL,BL
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC CL
        JNZ LOOP3

        POP ES					;pop in lifo fashion
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX        

INIT:						;this portion makes the code resident
        MOV AX,CS    				;Initialize data
        MOV DS,AX				;storing cs in ds

        CLI   					;Clear Interrupt Flag

        MOV AH,35H   				;Get Interrupt vector Data and store it ..... AH -> function call   AL -> interrupt number
        					;funtion 35 of interrupt 21h
        MOV AL,08H				;Getting interrupt vector address
        INT 21H					;call the interrupt.... es:bx=cs:ip

        MOV OLD_IP,BX				;
        MOV OLD_CS,ES

        MOV AH,25H   				;Set new Interrupt vector ..... function 25 of int21h
        MOV AL,08H				;store new cs:ip for int 8h
        LEA DX,MY_TSR				;load effective address for tsr
        INT 21H					

        MOV AH,31H   				;Make program Transient
        MOV DX,OFFSET INIT			;
        STI					;set interrupt flag
        INT 21H

CODE ENDS

END






;...Note
;1. The display ram starts at an 0B800h. This location refers to the first character on the first row of the screen. 
;This display buffer is actually a 4000 byte buffer to display 2000 characters(25 rows * 80 cols) .So each character requires 2 bytes.  
;The upper byte specifies the method in which the character should be displayed. While the lower byte is for ascii code.
;2. This upper byte has the following format

; Bl BBB FFFF

;where,
;Bl =1 Blinking, else static
;BBB=first 3 bits for background color, fourth bit assumed to be 0
;FFFF=4 bits for background color

;Colors
;A nibble represent color IRGB
;where

;    I=Intensity
;    R=Red
;    G=Green
;    B=Blue 


;So below is the color table

;    0000= Black
;    0001= Blue
;    0010= Green
;    0011= Cyan
;    0100= Red
;    0101=Magnetta
;    0110=Brown
;    0111=Light Gray
;    1000=Gray
;    1001=Light Blue
;    1010= Light Green
;    1100=Light Red
;    1101=Yellow
;    1111=White