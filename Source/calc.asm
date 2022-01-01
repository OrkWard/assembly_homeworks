.386
assume cs:code, ds:data, ss:stack_segment
data segment use16
	read_in db 100 dup(0); 用于存储读入的字符串
	result db 100 dup(0); 用于存储要输出的数
	number dd 0; 用于存储计算结果
	crlf db 0Dh, 0Ah, '$'; 回车换行
data ends

stack_segment segment
	tmp db 100 dup(0); 堆栈段, 用于转换数的方向
stack_segment ends

code segment use16
input:
	; 读入一行字符存储到read_in
	mov di, offset read_in
input_next:
	mov ah, 1
	int 21H
	cmp al, 0Dh; 判断AL是否为回车键
	je input_done
	mov [di], al
	inc di
	jmp input_next
input_done:
	mov byte ptr [di], 0
	ret

read_number:
	; 从read_in读入一个数保存在ebx, 该数的下一个字符保存在cl
	push eax
	mov bx, 0
read_chara:
	mov cl, [di]
	inc di
	cmp cl, '0'
	jb not_number
	cmp cl, '9'
	ja not_number
	sub cl, '0'
	mov eax, ebx
	mov ebx, 10
	mul ebx
	mov ebx, eax
	add bx, cx
	jmp read_chara
not_number:
	; 不是数字, 结束读入
	pop eax
	ret

main:
	mov ax, data
	mov ds, ax; ds指向data段
	mov ax, stack_segment
	mov ss, ax; ss指向stack_segment段
	call input
	mov di, offset read_in
	call read_number
	mov eax, ebx
calc:
	; 根据cl中存储的字符是*, /, +还是0决定下一步操作
	; eax始终存储最终计算结果(被加数, 被乘数, 被除数), ebx为操作数
	cmp cl, '*'
	jne division
	call read_number
	mul ebx
	jmp calc
division:
	cmp cl, '/'
	jne addition
	call read_number
	push di
	div ebx
	pop di
	jmp calc
addition:
	cmp cl, '+'
	jne output
	call read_number
	add eax, ebx
	jmp calc

output:
	; 输出部分函数
	; 先用计算结果分别除以10, 10H, 得到的余数压入堆栈, 再依次弹出得到结果
	mov [number], eax; 计算中eax会被覆盖, 先临时存储
	mov ebx, 10
	mov di, offset result
	mov dx, '$'; 先压入字符串结束标志
	push dx
dec_output:
	mov edx, 0
	div ebx
	add dl, '0'
	push dx
	cmp eax, 0
	ja dec_output
dec_repeat:
	pop dx
	mov [di], dl
	inc di
	cmp dl, '$'
	jne dec_repeat
	mov ah, 9h
	mov dx, offset result; 输出十进制计算结果
	int 21H
	mov dx, offset crlf; 换行
	int 21H
	
	mov eax, [number]
	mov ebx, 10H
	mov si, 0; 统计位数, 小于8位则需补零
	mov di, offset result
	mov dx, '$'
	push dx
hex_output:
	mov edx, 0
	div ebx
	cmp dl, 9
	ja not_digit
	add dl, '0'
	jmp add_number
not_digit:
	add dl, 'A' - 10
add_number:
	push dx
	inc si
	cmp eax, 0
	ja hex_output

	; 下面部分函数用于向堆栈压入缺少的零
add_zero:
	cmp si, 7
	ja hex_repeat
	mov dx, '0'
	push dx
	inc si
	jmp add_zero

hex_repeat:
	pop dx
	mov [di], dl
	inc di
	cmp dl, '$'
	jne hex_repeat
	mov ah, 9h
	mov dx, offset result; 输出16进制计算结果
	int 21H
	mov dx, offset crlf
	int 21H

	mov ah, 4CH
	int 21H 
code ends
end main