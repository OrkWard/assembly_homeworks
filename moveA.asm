code segment
assume cs:code
main:
   mov ax, 0B800h
   mov ds, ax
   mov di, 0
   mov al, 'A'
   mov ah, 17h; 蓝色背景,白色前景
   mov cx, 2000
again:
   mov ds:[di], ax
   mov bx, 2h
wait_wait:
   mov dx, 0
wait_a_while:
   sub dx, 1
   jnz wait_a_while
   sub bx, 1
   jnz wait_wait

   mov word ptr ds:[di], 0020h
   add di, 2
   sub cx, 1
   jnz again
   mov ah, 1
   int 21h; 相当于AL=getchar();
   mov ah, 4Ch
   int 21h
code ends
end main

