.model small
.stack 256

.data  
    matrix dw  -8,15,-19,-11,-31,-34,22,-41,28,19,-13,-23,-22,13,25,-44,-44,-1,25,49,-23,11,12,-32,29,11,-28,-37,-1,21,11,-46,31,17,30,-3,33,38,-20,-38,24,28,-17,-27,8,33,26,9,27,35,-25,-32,48,-34,50,29,38,-14,3,22,45,43,-11,28,-45,-35,6,-24,12,15,7,19,13,-19,13,18,-4,-10,-4,-35,37,-1,-3,-33,11,-42,-8,-11,14,36,-1,-7,-6,-3,19,-25,17,8,7,-15

    maxValue dw 32767
    matrixSize dw ?

    a dw 0
    upperSum dw 0
    lowerSum dw 0

    i dw 0
    j dw 0
    counter dw 0
    n dw 0

    negative dw 0
    positive dw 0

    sizeMessage db 'Enter your matrix size (0 < size <= 10):', 10, 's = ', '$'
    yourMatrixString db 'Your matrix: ', 10, '$'
    aMessage db 10, 'Enter a:', 10, 'a = ', '$'
    nextString db 10, '$'
    space db '  ', '$'
    invalidInputException db 10, 'Invalid input!', 10, '$'
    emptyException db 'String is empty!', 10, '$'
    upperSumString db 10, 'Upper sum = ', '$'
    lowerSumString db 10, 'Lower sum = ', '$'
    inputFile db 'input.txt', '$'

.code
.386

outputProc proc
   test ax, ax
   jns oi1

   mov  cx, ax
   mov  ah, 02h
   mov  dl, '-'
   int  21h
   mov  ax, cx
   neg  ax

oi1:  
    xor cx, cx
    mov bx, 10

oi2:
    xor dx, dx
    div bx

    push dx
    inc cx

    test ax, ax
    jnz oi2

    mov ah, 02h

oi3:
    pop dx

    add dl, '0'
    int 21h

    loop oi3
    ret
 
outputProc endp

sumProc proc
    mov ax, i
    mov bx, n

    cmp ax, bx
    jl lowerSumAdd

    cmp ax, bx
    jg upperSumAdd

upperSumAdd:
    mov ax, a
    cmp cx, ax
    jl stopSumProc

    add upperSum, cx
    ret

lowerSumAdd:
    mov ax, a
    cmp cx, ax
    jl stopSumProc

    add lowerSum, cx
    ret

stopSumProc:
    ret

sumProc endp

swap proc
    mov ax, i
    mov bx, n
    
    cmp ax, bx
    jg stopSwapProc

    mov ax, cx
    mov bx, 5
    idiv bx

    cmp dx, 0
    jne stopSwapProc

    mov bx,j ;bx=строки в матрице

    mov ax, matrixSize
    mul bx
    mov bx, ax

    mov ax, upperSum
    mov matrix[bx][si], ax
    ret

    mov ax, cx
    mov bx, 3
    idiv bx

    cmp dx, 0
    jne stopSwapProc

    mov bx,j ;bx=строки в матрице

    mov ax, matrixSize
    mul bx
    mov bx, ax

    mov ax, lowerSum
    mov matrix[bx][si], ax
    ret

stopSwapProc:
    ret
swap endp

inputProc proc
input:
    mov ah, 01h
    int 21h

    cmp al, 2dh ;сравнение с минусом
    je isNegative

    cmp al, 2bh ;сравнение с плюсом
    je isPositive

    cmp al, 30h
    jl invalidInput
    cmp al, 39h
    jg invalidInput

    sub al, 30h
    mov ah, 0

    mov bx, 10
    mov cx, ax

    jmp inputLoop

isNegative:
    cmp negative, 1
    je invalidInput

    mov negative, 1
    jmp input

isPositive:
    cmp positive, 1
    je invalidInput

    mov positive, 1 
    jmp input

inputLoop:
    mov ah, 01h
    int 21h

    cmp al, 0dh
    je endInput

    cmp al, 30h
    jl invalidInput
    cmp al, 39h
    jg invalidInput

    sub al, 30h
    cbw

    xchg ax, cx

    imul bx
    jo invalidInput

    add cx, ax
    jc invalidInput

    cmp negative, 1
    je inputLoop

    cmp cx, maxValue
    jo invalidInput

    cmp cx, 0
    je invalidInput

    jmp inputLoop

endInput:
    cmp negative, 1
    jne endAInput
    cmp cx, maxValue
    jo invalidInput
    neg cx
    jmp endAInput

endAInput:
    mov negative, 0
    mov positive, 0
    ret

inputProc endp

matrixOutputProc proc
matrixOutput:
    mov si,i ;si=столбцы в матрице
    mov bx,j ;bx=строки в матрице

    mov ax, matrixSize
    mul bx
    mov bx, ax

    mov ax, 2
    imul si
    add ax, bx
    mov si, ax

    mov ax,matrix[bx][si]
    call outputProc

    mov ah, 9
    lea dx, space
    int 21h

    inc i
    mov ax, i
    mov bx, matrixSize
    cmp ax, bx
    je continue1

    jmp matrixOutput

continue1:
    mov ah, 9
    lea dx, nextString
    int 21h

    mov i, 0

    inc j
    mov ax, j
    mov bx, matrixSize
    cmp ax, bx
    je endMatrixOutput

    jmp matrixOutput

endMatrixOutput:
    ret
matrixOutputProc endp



matrixInputProc proc
matrixInput:
    call inputProc

    mov si,i ;si=столбцы в матрице
    mov bx,j ;bx=строки в матрице

    mov ax, matrixSize
    mul bx
    mov bx, ax

    mov ax, 2
    imul si
    add ax, bx
    mov si, ax

    mov matrix[bx][si], cx

    inc i
    mov ax, i
    mov bx, matrixSize
    cmp ax, bx
    je continue0

    jmp matrixInput

continue0:
    mov i, 0

    inc j
    mov ax, j
    mov bx, matrixSize
    cmp ax, bx
    je endMatrixInput

    jmp matrixInput

endMatrixInput:
    ret
matrixInputProc endp



;##############################################################################
start:        
    mov ax, @data
    mov ds, ax 

sizeInput:
    mov ah, 9
    lea dx, sizeMessage
    int 21h
    call inputProc
    mov matrixSize, cx

    cmp matrixSize, 1
    jl invalidInput
    cmp matrixSize, 10
    jg invalidInput

    mov ah, 9
    lea dx, yourMatrixString
    int 21h
    call matrixInputProc
    mov j, 0
    mov i, 0

aInput:
    call matrixOutputProc
    mov ah, 9
    lea dx, aMessage
    int 21h
    call inputProc
    mov a, cx
    mov j, 0
    mov i, 0

greaterThenFound:
    mov si,i ;si=столбцы в матрице
    mov bx,j ;bx=строки в матрице

    mov ax, matrixSize
    mul bx
    mov bx, ax

    mov ax, 2
    imul si
    add ax, bx
    mov si, ax

    mov cx, matrix[bx][si]
    call sumProc

    inc i
    mov ax, i
    mov bx, matrixSize
    cmp ax, bx
    je continue2

    jmp greaterThenFound

continue2:
    inc n

    mov i, 0

    inc j
    mov ax, j
    mov bx, matrixSize
    cmp ax, bx
    je sumOutput

    jmp greaterThenFound

sumOutput:
    mov ah, 9
    lea dx, upperSumString
    int 21h
    mov ax, upperSum
    call outputProc

    mov ah, 9
    lea dx, lowerSumString
    int 21h
    mov ax, lowerSum
    call outputProc

    mov i, 0
    mov j, 0
    mov n, 0

matrixSwapElements:
    mov si,i ;si=столбцы в матрице
    mov bx,j ;bx=строки в матрице

    mov ax, matrixSize
    mul bx
    mov bx, ax

    mov ax, 2
    imul si
    add ax, bx
    mov si, ax

    mov cx, matrix[bx][si]
    call swap

    inc i
    mov ax, i
    mov bx, matrixSize
    cmp ax, bx
    je continue3

    jmp matrixSwapElements

continue3:
    inc n

    mov i, 0

    inc j
    mov ax, j
    mov bx, matrixSize
    cmp ax, bx
    je next

    jmp matrixSwapElements


next:
    mov i, 0
    mov j, 0
    mov ah, 9
    lea dx, nextString
    int 21h

    call matrixOutputProc
    jmp exit

invalidInput:
    mov ah, 9
    lea dx, invalidInputException
    int 21h

exit:
    mov ah, 4ch
    int 21h

end start