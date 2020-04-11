section .data
	arr dq 1.0,2.0,3.0,4.0
	size equ ($-arr)/8
	count dq size
	mean dq 0
	formatpf db "%f",10,0
	temp dq 0
	means dq 0
	sd dq 0
	variance dq 0
	msg1 db "Mean is: "
	len1 equ $-msg1
	msg2 db "Standard deviation is: "
	len2 equ $-msg2
	msg3 db "Variance is: "
	len3 equ $-msg3


section .txt
extern printf
	global main
main:
;*********MEAN***********
	mov rsi,arr			;move arr to rsi
	mov cl,size			;move size to cl
	finit				;initialize co-precessor
	fldz				;initialize st0 with 0
up:
	fadd qword[rsi]			;add value at rsi to st0
	add rsi,8			;increment rsi by 8
	dec cl				;decrement cl
	jnz up				;jump if not zero to up
	fidiv dword[count]		;divide st0 by count
	fstp qword[mean]		;store st0 in mean

	mov eax,4			;syscall for output
	mov ebx,1			;file descriptor
	mov ecx,msg1			;move address of msg1 to ecx
	mov edx,len1			;move length to edx
	int 0x80			;call kernel

	mov rdi,formatpf		;move format to rdi
	sub rsp,8			;decrement stack pointer by 8
	movsd xmm0,[mean]		;move content at mean to xmm0
	mov rax,1			;move 2 to rax
	call printf			;call printf
	add rsp,8			;increment stack pointer by 8

	

;***********STANDARD DEVIATION*********

	mov rsi,arr			;move arr to rsi
	mov cl,size			;move size to cl
	fldz				;initialize st0 with 0
repeat:
	fld qword[rsi]			;load top of stack with value at rsi
	fmul qword[rsi]			;multiply st0 with value at rsi
	fadd qword[temp]		;add temp to st0
	fstp qword[temp]		;store st0 to temp
	add rsi,8			;increment rsi by 8
	dec cl				;decrement cl
	jnz repeat			;jump if not zero to repeat	
	
	fld qword[temp]			;load top of stack with value at rsi
	fidiv dword[count]		;divide st0 by count
	fstp qword[temp]		;store st0 to temp

	fld qword[mean]			;load top of stack with value at rsi
	fmul qword[mean]		;multiply st0 with value at rsi
	fstp qword[means]		;store st0 to temp
	
	fld qword[temp]			;load top of stack with value at rsi
	fsub qword[means]		;subtract means from st0
	fst qword[variance]		;store st0 to variance
	fsqrt				;calculate squareroot of st0
	fstp qword[sd]			;store st0 to sd

	mov eax,4			;syscall for output
	mov ebx,1			;file descriptor
	mov ecx,msg2			;move address of msg1 to ecx
	mov edx,len2			;move length to edx
	int 0x80			;call kernel

	mov rdi,formatpf		;move format to rdi
	sub rsp,8			;decrement stack pointer by 8
	movsd xmm0,[sd]		;move content at mean to xmm0
	mov rax,1			;move 2 to rax
	call printf			;call printf
	add rsp,8			;increment stack pointer by 8
;**********VARIANCE******************
	mov eax,4			;syscall for output
	mov ebx,1			;file descriptor
	mov ecx,msg3			;move address of msg1 to ecx
	mov edx,len3			;move length to edx
	int 0x80			;call kernel


	mov rdi,formatpf		;move format to rdi
	sub rsp,8			;decrement stack pointer by 8
	movsd xmm0,[variance]		;move content at mean to xmm0
	mov rax,1			;move 2 to rax
	call printf			;call printf
	add rsp,8			;increment stack pointer by 8
	
	mov eax,1			;syscall for exit
	int 0x80			;call kernel



