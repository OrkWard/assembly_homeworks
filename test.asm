data segment
	text1 dw 'ab'
	text2 dd 'ab'
data ends

code segment
assume cs:code, ds:data
main:
	mov ax, data
	mov ds, ax
	mov ax, text1
	mov ax, [text1]
	mov ax, text1[1]
	mov ax, offset text1
	mov ah, 4Ch
	int 21h
code ends
end main