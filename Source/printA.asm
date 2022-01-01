assume cs:code
code segment
main:
    mov ax, 0B800h
    mov es, ax
    mov al, 'A'
    mov es:[0], al 
    mov al, 17h
    mov es:[1], al 
    mov ah, 1 
    int 21h
    mov ah, 4Ch 
    int 21h
code ends
end main