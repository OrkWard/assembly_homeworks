;--------------------------------------
;由于时间安排不当，程序并未完成，已完成的部分也没有经过调试
;基本上保持一句一句对应编写，没有必要声明的变量进行了舍弃
;每个函数中的FunctionName_next_N表示第N个循环，用next_next表示嵌套循环，用_fin/_fin_fin表示循环结束（如果有必要）
;--------------------------------------
.386
data segment use16
	t db "0123456789ABCDEF"
	s db "00000000:            |           |           |                             "
	box db "+----------+|          |+----------+"
	buf db 72 dup(0)
date ends

code segment use16
assume cs:code, ds:data
	char2hex:	;把8位数转化成16进制格式
		push bp
		mov bp, sp
		mov al, ss:[bp + 4]	;处理高4位
		mov cl, 4
		shr al, cl
		mov ah, 0
		mov ax, bx
		and bx, 0Fh
		mov ax, ss:[bp + 6]
		mov [ax], t[bx]
		mov bl, ss:[bp + 4]	;处理低4位
		mov bh, 0
		and bx, 0Fh
		mov ax, ss:[bp + 6]
		mov [ax + 1], t[bx]
		pop bp
		ret

	long2hex:	;把32位数转化为16进制格式
		push bp
		mov bp, sp
		sub sp, 2
		mov cx, 0
		long2hex_next:
			mov dx, ss:[bp + 6]	;循环左移8位
			mov ax, ss:[bp + 4]
			rol dx, 4
			mov bl, dl
			mov dl, ah
			mov ah, al
			mov al, bl
			mov ss:[bp + 6], dx
			mov ss:[bp + 4], ax
			and ax, 0FFh	;高24位置0, 保留低8位
			mov ss:[bp - 2], ax
			mov ax, ss:[bp + 8]
			add ax, cx
			add ax, cx
			push ax	;把8位数转化成16进制格式
			mov ax, ss:[bp - 2]
			push ax
			call char2hex
			add sp, 4
			inc cx
			cmp cx, 4
			jl long2hex_next
		mov sp, bp
		pop bp
		ret
	
	hex2long:;	16进制字符串转化成32位数
		push bp
		mov bp, sp
		sub sp, 6
		push si
		push di
		mov word ptr ss:[bp - 4], 0	;y = 0
		mov word ptr ss:[bp - 6], 0
		mov ax, ss:[bp + 4]
		mov si, 0FFFFh
		hex2long_count_string:	; strlen()
			inc si
			mov bx, [ax + si]
			cmp bx, 0
			jne hex2long_count_string
		mov ss:[bp - 2], si
		mov si, 0
		hex2long_next:
			mov di, 0
			hex2long_next_next:
				mov ax, t[di]
				mov bx, ss:[bp + 4]
				mov cx, [bx + si]
				cmp ax, cx
				je hex2long_fin
				inc di
				cmp di, 10h
				jl hex2long_next_next
			hex2long_fin:
			mov dx, ss:[bp - 4]	;y = (y << 4) | j
			mov ax, ss:[bp - 6]
			mov bx, 4
			shl dx, bx
			mov ah, dl
			mov al, ah
			mov al, 0
			or ax, di
			mov ss:[bp - 4], dx
			mov ss:[bp - 6], ax
			inc si
			cmp si, ss:[bp - 2]
			jl hex2long_next
		pop di
		pop si
		mov sp, bp
		pop bp
		ret

	show_this_row:	;显示当前一行
		push bp
		mov bp, sp
		sub sp, 2
		push si
		push es
		mov word ptr ss:[bp - 2], 0
		mov ax, 0B800h
		mov es, ax
		push offset s	;调用函数
		push ss:[bp + 8]
		push ss:[bp + 6]
		call long2hex
		add sp, 6
		xor si, si	;第一个循环，把buf中各个字节转化成16进制格式填入s中
		jmp show_this_row_fin_1
		show_this_row_next_1:
			mov ax, ss:[bp + 10]
			push [ax + si]
			mov ax, offset s
			add ax, 10
			mov bx, si
			add bx, si
			add bx, si
			add ax, bx
			push ax
			call char2hex
			add sp, 4
			inc si
		show_this_row_fin_1:
			cmp si, ss:[bp + 12]
			jl show_this_row_next_1
		xor si, si	;第二个循环，把buf中各个字节填入s右侧小数点处
		jmp show_this_row_fin_2
		show_this_row_next_2:
			mov ax, ss:[bp + 10]
			mov word ptr s[si + 59], [ax + si]
			inc si
		show_this_row_fin_2:
			cmp	si, ss:[bp + 12]
			jl show_this_row_next_2
		mov ax, ss:[bp + 4]
		mov bx, 170
		mul bx
		add ss:[bp - 2], ax	;计算row行对应的地址
		xor si, si	;第三个循环，输出s
		jmp show_this_row_fin_3
		show_this_row_next_3:
			mov ax, si
			shl ax, 1
			add ax, ss:[bp - 2]
			mov byte ptr es:ax, s[si]
			inc ax, 1
			cmp si, 59
			jae other_character
			cmp s[si], '|'
			jne other_character
				mov byte ptr es:ax, 0Fh
				jmp show_this_row_fin_3
			other_character:
				mov byte ptr es:ax, 07h
			inc si
		show_this_row_fin_3:
			cmp si, 75
			jl show_this_row_next_3
		pop es
		pop si
		mov sp, bp
		pop bp
		ret

	clear_this_page:	;清除屏幕0~15行
		push bp
		mov bp, sp
		push si
		push di
		push ds
		push es
		mov ax, 0B800h
		mov es, ax
		mov ds, ax
		mov cx, 1279
		mov si, 0
		mov di, 2
		mov word ptr es:si, 0020h
		rep stosw	;清空屏幕
		pop es
		pop ds
		pop di
		pop si
		pop bp
		ret
	
	show_this_page:	;显示当前页
		push bp
		mov bp, sp
		push si
		sub sp, 4
		call clear_this_page
		mov ax, ss:[bp + 0Ah]
		add ax, 15
		mov bl, 16
		div bl
		mov ss:[bp - 2]
		xor si, si
		jmp show_this_page_fin
		show_this_page_next:
			mov ax, ss:[bp - 2]
			dec ax
			cmp si, ax
			je show_this_page_next_equal
				mov ss:[bp - 4], 16
				jmp show_this_page_next_fin
			show_this_page_next_equal:
				mov ax, si
				mov bx, 16
				mul ax, bx
				mov bx, ss:[bp + 0Ah]
				sub bx, ax
				mov ss:[bp - 4], bx
			show_this_page_next_fin:
			push word ptr ss:[bp - 4]
			mov ax, si
			mov bx, 16
			mul bx
			add ax, ss:[bp + 4]
			push ax
			mov ax, si
			mov bx, 16
			mul bx
			add ax, ss:[bp + 6]
			mov dx, ss:[bp + 8]
			push dx
			push ax
			push si
			call show_this_row
			add sp, 0Ah
			inc si
		show_this_page_fin:
			cmp si, ss:[bp - 2]
			jl show_this_page_next
		pop si
		mov sp, bp
		pop bp
		ret

	get_offset:
		push bp
		mov bp, sp
		sub sp, 15h
		push si
		push di
		push ds
		push es
		mov word ptr ss:[bp - 6], 34
		mov word ptr ss:[bp - 8], 11
		mov word ptr ss:[bp - 2], 0
		mov word ptr ss:[bp - 4], 1828
		mov ax, data
		mov ds, ax
		mov ax, 0B800h
		mov es, ax
		xor si, si
		get_offset_next_1:
			xor di
			get_offset_next_1_next:
				mov ax, si
				mul 24
				add ax, di
				add ax, offset buf
				mov bx, di
				add bx, ss:[bp - 4]
				mov byte ptr ds:[ax], es:[bx]
				inc di
				cmp di, 24
				jl get_offset_next_1_next
			add ss:[bp - 4], 160
			inc si
			cmp si, 3
			jl get_offset_next_1
		xor si, si
		mov word ptr ss:[bp - 4], 1828
		get_offset_next_2:
			xor di
			get_offset_next_2_next:
				mov ax, si
				mul ax, 13
				add ax, di
				add ax, offset box
				mov bx, di
				shl bx, 1
				add bx, ss:[bp - 4]
				mov byte ptr es:[bx], ds:[ax]
				inc bx
				mov byte ptr es:[bx], 17h
				inc di
				cmp di, 12
				jl get_offset_next_2_next
			add ss:[bp - 4], 160
			inc si
			cmp si, 3
			jl get_offset_next_2
		mov word ptr ss:[bp - 4], 1990
		mov word ptr ss:[bp - 0Ah], 0
		get_offset_next_3:
			mov ah, 1
			int 16h
			mov ah, 0
			mov ss:[bp - 0Ch], ax
			cmp al, 8
			je backsapce
			cmp al, 13
			je enter
			cmp ah, 'a'
			jl not_lower
			cmp ah, 'f'
			ja not_lower
			sub ah, 20h
			not_lower:
			xor si, si
			get_offset_next_3_next:
				cmp al, t[si]
				je get_offset_next_3_fin
				inc si
				cmp si, 16
				jl get_offset_next_3_next
			get_offset_next_3_fin:
			cmp si, 16
			je get_offset_next_3
			cmp word ptr ss:[bp - 0Ah], 8
			je get_offset_next_3
			mov ax, bp
			sub ax, 15h
			add ax, ss:[bp - 0Ah]
			mov word ptr ss:[ax], ss:[bp - 0Ch]
			mov ax, ss:[bp - 0Ah]
			shl ax, 1
			add ax, ss:[bp - 4]
			mov word ptr es:[ax], ss:[bp - 0Ch]
			inc ax
			mov word ptr es:[ax], 17h
			add word ptr ss:[bp - 0Ah], 1
			cmp word ptr ss:[bp - 0Ch], 13
			jne get_offset_next_3
			backsapce:
				cmp ss:[bp - 0Ah], 0
				je get_offset_next_3
				mov ax, ss:[bp - 0Ah]
				dec ax
				shl ax, 1
				add ax, ss:[bp - 4]
				mov es:[ax], ' '
				inc ax
				mov es:[ax], 17h
				dec [bp - 0Ah]
				jmp get_offset_next_3
			enter:
				mov	ax, bp
				sub ax, 15h
				add ax, ss:[bp - 0Ah]
				mov ss:[ax], 0
				jmp get_offset_next_3
		mov word ptr ss:[bp - 4], 1828
		xor si, si
		get_offset_next_4:
			xor di
			get_offset_next_4_next:
				mov ax, si
				mul 24
				add ax, di
				add ax, offset buf
				mov bx, di
				add bx, ss:[bp - 4]
				mov byte ptr ds:[ax], es:[bx]
				inc di
				cmp di, 24
				jl get_offset_next_4_next
			add ss:[bp - 4], 160
			inc si
			cmp si, 3
			jl get_offset_next_4
		lea ax, [bp - 15h]
		push ax
		call hex2long
		pop es
		pop ds
		pop di
		pop si
		mov sp, bp
		pop bp
		ret

	main:
		mov ax, data
		mov ds, ax

code ends
