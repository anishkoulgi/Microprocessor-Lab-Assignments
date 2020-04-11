%macro print 4
mov eax,%1
mov ebx,%2
mov ecx,%3
mov edx,%4
int 80h
%endmacro

section .data
        rmsg db 10d,13d,"Processor is in Real Mode. "
        rlen equ $-rmsg
        pmsg db 10d,13d,"Processor is in Protected Mode. "
        plen equ $-pmsg
        gmsg db 10d,13d,"GDT Contents are "
        glen equ $-gmsg
        imsg db 10d,13d,"IDT Contents are "
        ilen equ $-imsg
        lmsg db 10d,13d,"LDT Contents are "
        llen equ $-lmsg
        col db ':'
        endl db 10d
        
section .bss

        gdt resd 1
            resw 1
        ldt resw 1
        idt resd 1
            resw 1
        answer resb 4

section .text
        global _start
_start:
;********** CHECK PROTECTED MODE**********
        smsw eax				;Store machine status word into eax
        bt eax,1				;check 1st bit of eax
        jc protected				;jump if carry to protected
        
        print 4,1,rmsg,rlen			;print rmsg
        jmp next1				;jump to next1
        
protected: print 4,1,pmsg,plen			;print pmsg
next1:  sgdt [gdt]				;load contents of gtdr to gdt
        sldt [ldt]				;load contents of ltdr to ldt
        sidt [idt]				;load contents of itdr to idt

        print 4,1,gmsg,glen			;print gmsg
        mov ax,[gdt+4]				;move address of gdt+4 to ax
        call display				;call display
        mov ax,[gdt+2]				;move address of gdt+2 to ax
        call display				;call display
        mov ax,[gdt]				;move address of gdt to ax
        call display				;call display

        print 4,1,imsg,ilen			;print imsg
        mov ax,[idt+4]				;move address of idt+4 to ax
        call display				;call display
        mov ax,[idt+2]				;move address of idt+2 to ax
        call display				;call display
        mov ax,[idt]				;move address of idt to ax
        call display				;call display

        print 4,1,lmsg,llen			;print lmsg
        mov ax,[ldt]				;move address of ldt to ax
        call display        			;call display
        
        print 4,1,endl,1			;print endl
        mov eax,1				;syscall for exit
        int 80h					;call kernel

;************DISPLAY PROCEDURE************
	
display:
	mov esi,answer+3			;move address answer+3 to esi
	mov ecx,4				;initialize counter to 4
	mov bx,ax				;move contents of ax to bx
cont:
	rol bx,4				;rotate bx by 4
	mov ax,bx				;move contents of bx to ax
	and ax,0x000f				;and ax with 0x000f
	cmp ax,0xa				;compare ax with 0xa
	js down					;jump if sign bit is set to down
	add al,0x07				;add 07 to al
down:
	add al,0x30				;add 0x30 to al
	mov byte[esi],al			;move contents of al to address in esi
	dec esi					;decrement esi
	dec ecx					;decrement ecx
	jnz cont				;jump if not zero to cont
	print 4,1,answer,4			;print answer
	ret					;return to main procedure

