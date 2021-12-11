.model small
.data
matrix          dw 10 dup(10 dup(?))
temp_matrix     dw 10 dup(10 dup(?))
matrix_size     dw ?
det             dw 0
i               dw 0
j               dw 0
for_index       dw 0
temp_index      dw 0
minus_one       dw -1
d               dw 0
count           dw 0
end_line        db 13, 10, '$'
maxlen          db 3
len             db 0
buffer          db 6 dup(0)
string          db 255 dup(0)
res_msg         db "Matrix determinant: $"
enter_msg       db "Enter matrix size: $"
read_msg        db "Reading from file$"
write_msg       db "Writing to file$"
space           db " $"
input_file      db "input.txt", 0
output_file     db "output.txt", 0
;input_txt       db "23 14 11 10 -7 -1 -5 -7 17 -5 16 1 14 -8 5 14 0 5 22 -6 11 13 5 12 16 15 8 24 8 17 20 10 16 22 -3 11 22 24 14 18 0 -1 19 4 17 24 14 7 -3 -5 10 14 17 -3 23 4 -2 -5 10 1 -4 7 12 -1 5 16 14 24 17 0 20 -9 -2 22 -2 3 -3 -5 20 16 8 "
input_txt       db "3 1 -3 -1 -2 -3 -1 8 7 10 1 7 -8 9 7 -6 -1 6 4 -7 6 8 -4 4 -1 -7 9 1 9 -1 3 -7 6 -7 3 -9 1 -6 2 -5 8 9 -2 -5 -9 -4 -6 8 -1 -4 -4 10 -8 8 -8 -1 -8 9 7 6 1 4 -7 0 4 -2 3 4 -1 9 1 1 -7 -6 3 -1 -2 -6 -3 -8 -3 10 -8 -8 -3 -4 6 -6 0 -4 2 10 8 0 0 -1 3 -2 9 -7 "
.code

to_string proc
    push bx
    push cx
    push dx
    push si
    push di
    mov di, 10
    mov cx, 0
    lea bx, buffer
    test ax, ax
    jns to_string_cycle
    neg ax
    mov [bx], '-'
    inc bx

to_string_cycle:
    push ax
    mov al, len
    inc ax
    mov len, al
    pop ax
    inc cx
    mov dx, 0
    div di
    add dx, 30h
    push dx
    cmp ax, 0
    jne to_string_cycle
to_string_cycle_2:
    pop [bx]
    inc bx
    loop to_string_cycle_2
    inc bx
    mov [bx], '$'
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
to_string endp

convert proc
    push bx
    push cx
    push dx
    push si
    push di

convert_start:
    lea bx, len
    mov cx, [bx]
    xor ch, ch
    mov di, 0
    mov si, 1

convert_cycle:
    push si
    mov si, cx
    mov ax, [bx + si]
    pop si
    cmp al, '0'
    jl convert_check
    cmp al, '9'
    jg convert_check
    xor ah, ah
    sub ax, 30h
    mul si
    add di, ax
    mov ax, si
    mov si, 10
    mul si
    jo convert_check_2
    mov si, ax
    loop convert_cycle

convert_plus:
    mov ax, di
    cmp ax, 32767
    ja convert_error_point
    jmp convert_return

convert_minus:
    mov ax, di
    cmp ax, 32768
    ja convert_error_point
    xor ax, ax
    sub ax, di

convert_return:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

convert_check:
    cmp cx, 1
    jne convert_error_point
    cmp al, '-'
    jne convert_error_point
    cmp di, 0
    jne convert_minus

convert_error_point:
    jmp convert_start

convert_check_2:
    cmp cx, 1
    je convert_plus
    dec cx
    cmp cx, 1
    jne convert_error_point
    mov si, cx
    mov bl, [bx + si]
    cmp bl, '-'
    je convert_minus
    jmp convert_error_point
convert endp

input proc
    push bx
    push cx
    push dx
    push si
    push di

in_start:
    lea dx, maxlen
    mov ah, 0ah
    int 21h
    lea bx, len
    mov cx, [bx]
    xor ch, ch
    mov di, 0
    mov si, 1

in_cycle:
    push si
    mov si, cx
    mov ax, [bx + si]
    pop si
    cmp al, '0'
    jl check
    cmp al, '9'
    jg check
    xor ah, ah
    sub ax, 30h
    mul si
    add di, ax
    mov ax, si
    mov si, 10
    mul si
    jo check_2
    mov si, ax
    loop in_cycle

plus:
    mov ax, di
    cmp ax, 32767
    ja error_point
    jmp return

minus:
    mov ax, di
    cmp ax, 32768
    ja error_point
    xor ax, ax
    sub ax, di

return:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

check:
    cmp cx, 1
    jne error_point
    cmp al, '-'
    jne error_point
    cmp di, 0
    jne minus

error_point:
    jmp in_start

check_2:
    cmp cx, 1
    je plus
    dec cx
    cmp cx, 1
    jne error_point
    mov si, cx
    mov bl, [bx + si]
    cmp bl, '-'
    je minus
    jmp error_point
input endp

output proc
    push bx
    push cx
    push dx
    push si
    push di
    mov di, 10
    mov cx, 0
    lea bx, buffer
    test ax, ax
    jns out_cycle
    neg ax
    mov [bx], '-'
    inc bx

out_cycle:
    inc cx
    mov dx, 0
    div di
    add dx, 30h
    push dx
    cmp ax, 0
    jne out_cycle

out_cycle_2:
    pop [bx]
    inc bx
    loop out_cycle_2
    inc bx
    mov [bx], '$'
    lea dx, buffer
    mov ah, 09h
    int 21h
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
output endp

index proc
    push dx
    mov ax, i
    mul for_index
    add ax, j
    add ax, j
    pop dx
    ret
index endp

show_matrix proc
    push ax
    push cx
    push dx
    push di
    push si
    mov di, 0

show_matrix_:
    mov cx, 0

show_matrix_2:
    mov i, di
    mov j, cx
    call index
    mov si, ax
    mov ax, [bx + si]
    cmp ax, 10
    jge skip2
    cmp ax, 0
    jl skip2
    push ax
    lea dx, space
    mov ah, 09h
    int 21h
    pop ax

skip2:
    call output
    inc cx
    cmp cx, matrix_size
    jne show_matrix_2
    lea dx, end_line
    mov ah, 09h
    int 21h
    inc di
    cmp di, matrix_size
    jne show_matrix_
    pop si
    pop di
    pop dx
    pop cx
    pop ax
    ret
show_matrix endp

create proc
    push i
    push j
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ax, d
    add ax, 2
    mov d, ax
    mov bx, 1
    ;inc bx

new:
    mov dx, 0

new2:
    cmp j, dx
    je skip 
    mov i, bx
    push j
    mov j, dx
    call index
    pop j
    mov si, ax
    push [matrix + si]
    mov si, temp_index
    pop [temp_matrix + si]
    add si, 2
    mov temp_index, si

skip:
    mov ax, matrix_size
    dec ax
    cmp dx, ax
    jne next
    mov si, temp_index
    add si, d
    mov temp_index, si

next:
    inc dx
    cmp dx, matrix_size
    jne new2
    inc bx
    cmp bx, matrix_size
    jne new

    mov bx, 0
    mov cx, matrix_size

cycle:
    push cx
    mov cx, matrix_size
    mov dx, 0

cycle2:
    mov i, bx
    mov j, dx
    call index
    mov si, ax
    push [temp_matrix + si]
    pop [matrix + si]
    inc dx
    loop cycle2
    pop cx
    inc bx
    loop cycle
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop j
    pop i
    ret
create endp

find_det proc
    mov ax, matrix_size
    cmp ax, 1
    jne contin
    mov ax, matrix
    ret

contin:
    mov bx, 0

sum:
    mov i, 0
    mov j, bx
    call index
    mov si, ax
    mov ax, -1
    imul minus_one
    mov minus_one, ax
    mov ax, [matrix + si]
    imul minus_one
    mov cx, ax

    push det
    push cx
    push matrix_size
    mov di, 0
    mov si, 0
    push ax
    mov ax, matrix_size
    mul ax
    mov dx, ax
    pop ax

pushing:
    push [matrix + si]
    add si, 2
    inc di
    cmp di, dx
    jne pushing
    push si
    push di
    push d
    push temp_index
    push minus_one
    call create
    jmp sum3

sum2:
    jmp sum

sum3:
    push ax
    mov ax, matrix_size
    dec ax
    mov matrix_size, ax
    mov ax, 0
    mov temp_index, ax
    mov det, ax
    mov ax, -1
    mov minus_one, ax
    pop ax
    push bx
    call find_det
    pop bx
    pop minus_one
    pop temp_index
    pop d
    pop di
    pop si
    sub si, 2

popping:
    pop [matrix + si]
    sub si, 2
    dec di
    cmp di, 0
    jne popping
    pop matrix_size
    pop cx
    imul cx
    pop det

    add det, ax
    inc bx
    cmp bx, matrix_size
    jne sum2
    mov ax, det
    ret
find_det endp

main:
    mov ax, @data
    mov ds, ax

    mov ah, 3Ch
    mov cx, 7
    lea dx, input_file
    int 21h

    mov ax, 3D01h
    lea dx, input_file
    int 21h

    mov bx, ax
    mov ah, 40h
    lea dx, input_txt
    mov cx, 254
    int 21h

    mov ah, 3Eh
    int 21h

    lea dx, enter_msg
    mov ah, 09h
    int 21h
    call input
    push ax
    lea dx, end_line
    mov ah, 09h
    int 21h
    pop ax
    mov matrix_size, ax
    mov ax, matrix_size
    mov bx, 2
    mul bx
    mov for_index, ax

    lea dx, read_msg
    mov ah, 09h
    int 21h
    lea dx, end_line
    mov ah, 09h
    int 21h

    mov ax, 3D00h
    lea dx, input_file
    int 21h

    mov bx, ax
    mov ah, 3Fh
    mov cx, 254
    lea dx, string
    int 21h

    mov ah, 3Eh
    int 21h

    lea di, buffer
    lea bx, string
    mov ax, matrix_size
    mul ax
    mov count, ax
    mov cx, 0
    mov ax, 0
    mov si, 0

split:
    mov dl, [bx]
    cmp dl, 32
    je fill
    push [bx]
    pop [di]
    inc di
    inc ax
    mov len, al
    jmp no_fill

fill:
    call convert
    mov matrix + si, ax
    add si, 2
    lea di, buffer
    mov ax, 0
    inc cx

no_fill:
    inc bx
    cmp cx, count
    jne split

    lea bx, matrix
    call show_matrix

    call find_det
    push ax
    lea dx, res_msg
    mov ah, 09h
    int 21h
    pop ax
    call output
    lea dx, end_line
    mov ah, 09h
    int 21h

    mov bx, 0

edit:
    mov cx, 0

edit2:
    mov i, bx
    mov j, cx
    call index
    mov si, ax
    mov ax, [matrix + si]
    cmp ax, det
    je increase
    jg reduce
    jmp point

increase:
    cmp ax, 0
    jl for_minus
    mov di, 7
    imul di
    mov di, 5
    idiv di
    mov [matrix + si], ax
    jmp point

for_minus:
    mov di, 3
    imul di
    mov di, 5
    idiv di
    mov [matrix + si], ax
    jmp point

reduce:
    cmp ax, 0
    jl for_minus2
    mov di, 4
    imul di
    mov di, 5
    idiv di
    mov [matrix + si], ax
    jmp point
    
for_minus2:
    mov di, 6
    imul di
    mov di, 5
    idiv di
    mov [matrix + si], ax
    jmp point

edit3:
    jmp edit

point:
    inc cx
    cmp cx, matrix_size
    jne edit2
    inc bx
    cmp bx, matrix_size
    jne edit3

    lea dx, write_msg
    mov ah, 09h
    int 21h
    lea dx, end_line
    mov ah, 09h
    int 21h

    lea bx, matrix
    call show_matrix

    mov bx, 0
    mov len, bl
    lea di, string

write:
    mov cx, 0

write2:
    mov i, bx
    mov j, cx
    call index
    mov si, ax
    mov ax, matrix + si
    cmp ax, 0
    jge write_skip
    push ax
    mov al, len
    inc al
    mov len, al
    pop ax

write_skip:
    call to_string
    push bx
    lea bx, buffer

write_rep:
    cmp [bx], '$'
    je write_next
    push [bx]
    pop [di]
    inc di
    inc bx
    jmp write_rep

write_next:
    pop bx
    mov al, len
    inc al
    mov len, al
    inc cx
    cmp cx, matrix_size
    jne write2
    mov [di], 10
    inc di
    mov al, len
    inc al
    mov len, al
    inc bx
    cmp bx, matrix_size
    jne write

    mov ah, 3Ch
    mov cx, 7
    lea dx, output_file
    int 21h

    mov ax, 3D01h
    lea dx, output_file
    int 21h

    mov bx, ax
    mov ah, 40h
    mov cl, len
    lea dx, string
    int 21h

    mov ah, 3Eh
    int 21h

exit:
    mov ah, 4ch
    int 21h
end main