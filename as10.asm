;E-1 BATCH
;ROLL NUMBER: 21105


section .data
	four dq 4.00
	two dq 2.00
	a dq 1.00
	b dq 2.00
	c dq 1.00
	delta dq 0
	formatlf db "1st root is: %lf",10, "2nd root is: %lf",10,0
	formatsf db "%lf",0
	endl db 0xa
	inputMessage dq 'Enter Coefficients(a,b,c) of ax^2+bx+c=0 ',0xa
	length equ $-inputMessage
	errorMessage dq 'Invalid Quadratic Equation',10
	errorlng equ $-errorMessage	
	formatlfip db "1st root is: %lf + %lfi",10,0
	formatlfin db "2nd root is: %lf - %lfi",10,0
	
section .bss
	res1 rest 1
	res2 rest 1

section .text
	global main		;main for printf
	extern printf		;import printf		
	extern scanf		;import scanf

main:
	mov eax,4		;syscall for output
	mov ebx,1		;file descriptor
	mov edx,length		;length of message
	mov ecx,inputMessage	;address of message
	int 0x80

	mov rdi,formatsf	;move format to edi
	mov rax,0		;move 0 to rax
	sub rsp,8		;decrement stack pointer by 8
	mov rsi,rsp		;move value of rsp to rsi
	call scanf		;call scanf function
	mov r8,qword[rsp]	;move value stored at address in rsp to r8
	mov qword[a],r8		;move value in r8 to a
	add rsp,8		;increment stack pointer by 8

	mov rdi,formatsf	;move format to rdi
	mov rax,0		;move 0 to rax
	sub rsp,8		;decrement stack pointer by 8
	mov rsi,rsp		;move value of rsp to rsi
	call scanf		;call scanf function
	mov r8,qword[rsp]	;move value stored at address in rsp to r8
	mov qword[b],r8		;move value in r8 to b
	add rsp,8		;increment stack pointer by 8

	mov rdi,formatsf	;move format to edi
	mov rax,0		;move 0 to rax
	sub rsp,8		;decrement stack pointer by 8
	mov rsi,rsp		;move value of rsp to rsi
	call scanf		;call scanf function
	mov r8,qword[rsp]	;move value stored at address in rsp to r8
	mov qword[c],r8		;move value in r8 to c
	add rsp,8		;increment stack pointer by 8

	cmp qword[a],0		;check if a is zero
	je errorm		;jump to error if a is zero

	finit			;initialize co-processor
	fld qword[a]		;load top of stack with a
	fmul qword[c]		;multiply top of stack with c
	fmul qword[four]	;multiply top of stack with four
	fld qword[b]		;load top of stack with b
	fmul qword[b]		;multiply top of stack with b
	fsub st0,st1		;subtract st0 by st1
	fst qword[delta]	;store st0 to delta
	cmp qword[delta],0	;compare delta with 0
	jl down			;jump if less to down

	fld qword[delta]	;load top of stack with delta
	fsqrt			;calculate square root of st0
	fdiv qword[two]		;divide top of by two
	fdiv qword[a]		;divide top of by a
	fstp qword[delta]	;store st0 to delta and pop
	fld qword[b]		;load top of stack with b
	fchs			;compliment st0
	fdiv qword[two]		;divide top of by two
	fdiv qword[a]		;divide top of by a
	fadd qword[delta]	;add delta to st0
	fstp qword[res1]	;store st0 to delta and pop

	fld qword[b]		;load top of stack with b
	fchs			;compliment st0	
	fdiv qword[two]		;divide top of by two
	fdiv qword[a]		;divide top of by a
	fsub qword[delta]	;subtract delta from st0
	fstp qword[res2]	;store st0 to res2 and pop
	jmp print		;jump to print
down:
	fldz			;initialize top of stack to 0
	fld qword[delta]	;load top of stack with delta
	fchs			;compliment st0
	fsqrt			;calculate square root of st0
	fdiv qword[two]		;divide top of by two
	fdiv qword[a]		;divide top of by a
	fstp qword[res2]	;store st0 to res2 and pop
	fld qword[b]		;load top of stack with b
	fchs			;compliment st0	
	fdiv qword[two]		;divide top of by two
	fdiv qword[a]		;divide top of by a
	fstp qword[res1]	;store st0 to res1 and pop

	mov rdi,formatlfip	;move format to rdi
	sub rsp,8		;decrement stack pointer by 8
	movsd xmm0,[res1]	;move content at res1 to xmm0
	movsd xmm1,[res2]	;move content at res2 to xmm1
	mov rax,2		;move 2 to rax
	call printf		;call printf
	add rsp,8		;increment stack pointer by 8
	
	mov rdi,formatlfin	;move format to rdi
	sub rsp,8		;decrement stack pointer by 8
	movsd xmm0,[res1]	;move content at res1 to xmm0
	movsd xmm1,[res2]	;move content at res2 to xmm1
	mov rax,2		;move 2 to rax
	call printf		;call printf
	add rsp,8		;increment stack pointer by 8
	jmp exit		;jump to exit	
print:
	mov rdi,formatlf	;move format to rdi
	sub rsp,8		;decrement stack pointer by 8
	movsd xmm0,[res1]	;move content at res1 to xmm0
	movsd xmm1,[res2]	;move content at res2 to xmm1
	mov rax,2		;move 2 to rax
	call printf		;call printf
	add rsp,8		;increment stack pointer by 8
	jmp exit		;jump to exit
errorm:
	mov eax,4		;syscall for output
	mov ebx,1		;file descriptor
	mov ecx,errorMessage	;move address of errormessage to ecx
	mov edx,errorlng	;move length of error message to edx
	int 0x80		;call kernel
	
exit:
	mov eax,1		;syscall for exit
	int 0x80		;call kernel
