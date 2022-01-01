.386
.model flat, stdcall
option casemap :none

include include\windows.inc
include include\kernel32.inc
include include\user32.inc

includelib lib\kernel32.lib
includelib lib\user32.lib

.data
result db 100 dup(0); dup:duplicate重复
;char result[100]={0};
format db "%d",0; db:define byte字节类型
; char format[3]="%d";
prompt db "The result",0

.code
main:         ; 标号
    mov eax, 0; eax:extended ax
    mov ebx, 1
again: 
    add eax, ebx; eax=0+1+2+3
    add ebx, 1  ; ebx=4
    cmp ebx, 100; cmp:compare
    jbe again   ; jbe:jump if below or equal
invoke wsprintf, offset result, offset format, eax
invoke MessageBox,0,offset result,offset prompt,0
    ret
end main; 指定程序的起始执行点
         ; end后面的标号决定了程序刚开始
         ; 运行时的eip的值。






