

code segment
              
     assume cs:code,ds:code
start: mov ax,cs
     mov ds,ax			;initliaze ds
     mov cl,0			;initialize cl
     mov ch,0			;initialize ch

task1: 
	 inc cl			;increment cl
     cmp cl,0			;compare cl with 0
     je exit			;jump if equal to exit
     mov ax,0b800h		;move address of video ram to ax
     mov es,ax			;move content of ax to es
     mov si,1830		;initialze position of video ram

     mov al,'A'			;move data to al
     mov ah,93h			;move 93h to ah
     mov es:[si],ax		;move ax to es

     mov al,'n'			;move data to al
     mov ah,0A1h		;move color to ah
     inc si				;increment si
     inc si				;increment si

     mov es:[si],ax		;move ax to es
	 mov al,'i'			;move data to al
     mov ah,93h			;move color to ah
     inc si				;increment si
     inc si				;increment si

     mov es:[si],ax		;move ax to es
     mov al,'s'			;move data to al
     mov ah,0ffh		;move color to ah
     inc si				;increment si
     inc si				;increment si

     mov es:[si],ax		;move ax to es
     mov al,'h'			;move data to al
     mov ah,93h			;move color to ah
     inc si				;increment si
     inc si				;increment si

     mov es:[si],ax		;move ax to es
     call delay			;call delay function

     jmp task2			;jump to task2



task2: 
	 inc cl				;increment cl
     cmp cl,0			;compare cl with 0
     je exit			;jump if equal to exit	
     mov ax,0b800h		;move address of video ram to ax
     mov es,ax			;move ax to es
     mov si,1850		;initialze position of video ram
     mov al,'T'			;move data to al
      mov ah,0A1h		;move color to ah
     mov es:[si],ax		;move ax to es
     inc bh				;increment bh
     mov al,'2'			;move data to al
     mov ah,0A1h		;move color to ah
     inc si				;increment si
     inc si				;increment si

     mov es:[si],ax		;move ax to es
     call delay			;call delay function

     jmp task2			;jump to task2


     delay proc near
     mov ax,0fffh		;initialize delay counter
d2:
	 mov dx,0fffh		;initialize delay counter
d1:
	 nop				;no operation
     nop				;no operation
     dec dx				;decrement dx
     jnz d1				;jump if not zero to d1
     dec ax				;decrement ax
     jnz d2				;jump if not zero to d2
     ret				;return
     endp				;end proc


exit:
    mov ah,4ch			;syscall for exit
    int 21h				;call kernel

code ends
end start
