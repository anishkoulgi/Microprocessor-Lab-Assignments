section .data 
	choice db 0,0,0,0,0,0,0,0,0,0
	filename1 db 0,0,0,0,0,0,0,0,0,0,0
	filename2 db 0,0,0,0,0,0,0,0,0,0,0
	endl db 0xa
	file1_contents db 48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
	dummy db "file.txt",0,0,0
	msg db "File copied succcessfully!",0xa
	msglen equ $-msg
	msg2 db "File deleted succcessfully!",0xa
	msg2len equ $-msg2

section .bss
	cnt resd 1
	file_desc1 resb 4
	file_desc2 resb 4

section .text
	global _start:
_start:
	pop rbx
	pop rbx
	pop rbx
	mov rax,[rbx]
	mov [choice],rax
	pop rbx
	mov rax,[rbx]
	mov [filename1],rax
	pop rbx
	mov rax,[rbx]
	mov [filename2],rax



	mov eax, 5
  	mov ebx, filename1
 	mov ecx, 2             ;for read only access
 	mov edx, 0777          ;read, write and execute by all
   	int  0x80

	mov [file_desc1],eax


;********************************READ CONTENTS OF 1st FILE********************************************

	mov esi,file1_contents	;move address of numbers to esi
cont:	mov eax,3		;syscall for read
	mov ebx,[file_desc1]	;move value in filedesc to ebx	
	mov ecx,esi		;move address of string to ecx
	mov edx,1		;length of input	
	int 0x80		;call kernel
	inc esi			;increment esi
	inc byte[cnt]
	cmp eax,0		;compare eax with 0
	jne cont		;jump if not equal cont
	
	dec byte[cnt]
	
	mov eax, 6
   	mov ebx, [file_desc1]
	int 0x80

	
	cmp byte[choice],0x74
	je TYPE
	cmp byte[choice],0x63
	je COPY
	cmp byte[choice],0x64
	je DELETE
;********************************TYPE CONTENTS OF FILE 1********************************************

TYPE:
	mov eax,4
	mov ebx,1
	mov ecx,file1_contents
	mov edx,[cnt]
	int 0x80
	jmp exit

;********************************COPY FILE 1 TO FILE 2********************************************

COPY:
	mov eax, 5
  	mov ebx, filename2
 	mov ecx, 2             ;for read only access
 	mov edx, 0777          ;read, write and execute by all
   	int  0x80

	mov [file_desc2],eax

	mov edx,[cnt]          ;number of bytes
   	mov ecx,file1_contents         ;message to write
   	mov ebx,[file_desc2]    ;file descriptor 
   	mov eax,4            ;system call number (sys_write)
   	int 0x80             ;call kernel

	mov eax,4
	mov ebx,1
	mov ecx,msg
	mov edx,msglen
	int 0x80

	jmp exit

;********************************DELETE FILE 1********************************************

DELETE:

	mov eax, 10        ; system call 10: unlink
	mov ebx, filename1 ; file name to unlink
	int 80h            ; call into the system

	mov eax,4
	mov ebx,1
	mov ecx,msg2
	mov edx,msg2len
	int 0x80

exit:
	mov eax,1
	int 0x80
