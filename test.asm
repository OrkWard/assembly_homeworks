.386
data segment use16
data ends

code segment use16
assume cs:code
main:
	mov eax, 10h
	mov ebx, 10
	mul bx
	mov ax, 0
	mov bx, 0
	jmp eax
	mov ah, 4Ch
	int 21h
code ends
end main