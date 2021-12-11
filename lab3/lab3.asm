;Если a = c ^ 2 то
;     Результат = с / (a * b) + d
; Иначе
;     Если  c - b <> a ^ 2 + b ^ 3 то
;      Результат = a AND (b - c)
;   Иначе
;      Результат = a/b/c+(b^2+c^3)/d

.model small
.stack 256

.data
startMessage db 'Enter values.',10,10,'$'
aMessage db 'A=$'
bMessage db 'B=$'
cMessage db 'C=$'
dMessage db 'D=$'
overflowException db 10,'Overflow exception!',10,10,'$'
divisionByZeroException db 10,'division by zero exception!',10,10,'$'
invalidInputException db 10,'Invalid input!',10,10,'$'
resultMessage db 10,'The result stored in ax is :',10,'$'
moreThenException db 10,'Ivalid input (> 32 767):',10,10,'$'
lessThenException db 10,'Ivalid input (< -32 768):',10,10,'$'

a dw 0
b dw 0
c dw 0  
d dw 0
count dw 0
maxValue dw 32767

enteredA dw 0
enteredB dw 0
enteredC dw 0
enteredD dw 0

negative dw 0
positive dw 0

.code
.386

input proc
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

input endp

start:
    mov ax, @data
    mov ds, ax

startFunc:
    lea dx, startMessage
    mov ah, 09h
    int 21h

aEnter:
    lea dx, aMessage
    mov ah, 09h
    int 21h
    jmp input

bEnter:
    lea dx, bMessage
    mov ah, 09h
    int 21h
    jmp input

cEnter:
    lea dx, cMessage
    mov ah, 09h
    int 21h
    jmp input

dEnter:
    lea dx, dMessage
    mov ah, 09h
    int 21h
    jmp input

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
    jo overflow

    add cx, ax
    jc overflow

    cmp negative, 1
    je inputLoop

    cmp cx, maxValue
    jo moreThen

    cmp cx, 0
    je overflow

    jmp inputLoop

endInput:
    cmp negative, 1
    jne endAInput
    cmp cx, maxValue
    jo lessThen
    neg cx

endAInput:
    cmp enteredA, 0
    jne endBInput
    mov a, cx
    mov enteredA, 1
    mov negative, 0
    mov positive, 0
    jmp bEnter

endBInput:
    cmp enteredB, 0
    jne endCInput
    mov b, cx
    mov enteredB, 1
    mov negative, 0
    mov positive, 0
    jmp cEnter

endCInput:
    cmp enteredC, 0
    jne endDInput
    mov c, cx
    mov enteredC, 1
    mov negative, 0
    mov positive, 0
    jmp dEnter

endDInput:
    cmp enteredD, 0
    jne firstIf
    mov d, cx
    mov enteredD, 1
    mov negative, 0
    mov positive, 0

firstIf: ;a = c ^ 2
    mov ax, c   ;ax = c
    imul ax  ;ax = c ^ 2
    jo overflow
    mov cx, ax  ;cx = c ^ 2

    mov ax, a   ;ax = a

    cmp ax, cx
    jne secondIf

firstResult:    ;Результат = с / (a * b) + d
    mov ax, a   ;ax = a
    mov bx, b   ;bx = b
    mov cx, d   ;cx = d

    imul bx  ;ax = a * b
    jo overflow
    mov bx, ax  ;bx = a * b
    cmp bx, 0
    je divisionByZero
    mov ax, c   ;ax = c

    idiv bx  ;ax = c / (a * b)
    add ax, cx  ;ax = c / (a * b) + d
    
    jmp output

secondIf:   ;c - b <> a ^ 2 + b ^ 3
    mov ax, a   ;ax = a
    mov bx, a
    imul bx  ;ax = a ^ 2     
    jo overflow

    mov cx, ax  ;cx = a ^ 2
    mov ax, cx

    mov bx, b   ;bx = b
    mov ax, b   ;ax = b
    imul bx  ;ax = b ^ 2
    jo overflow
    imul bx  ;ax = b ^ 3
    jo overflow
    add ax, cx  ;ax = a ^ 2 + b ^ 3
    jo overflow

    mov bx, c   ;bx = c
    mov cx, b   ;cx = b
    sub bx, cx  ;bx = c - b

    cmp ax, bx
    je thirdResult

secondResult:   ;Результат = a AND (b - c)
    mov ax, a   ;ax = a
    mov bx, b   ;bx = b

    sub bx, c   ;bx = b - c
    and ax, bx  ;ax = a AND (b - c)

    jmp output

thirdResult:    ;Результат = a/b/c+(b^2+c^3)/d
    mov ax, b   ;ax = b
    imul ax  ;ax = b ^ 2
    jo overflow

    mov bx, ax  ;bx = b ^ 2
    mov ax, c   ;ax = c
    mov cx, c   ;cx = c

    imul ax  ;ax = c ^ 2
    jo overflow
    imul cx  ;ax = c ^ 3
    jo overflow
    add ax, bx  ;ax = c ^ 3 + b ^ 2
    jo overflow
    mov bx, d   ;bx = d
    cmp bx, 0   
    je divisionByZero
    idiv bx  ;ax = (c ^ 3 + b ^ 2) / d
    mov cx, ax  ;cx = (c ^ 3 + b ^ 2) / d

    mov ax, a   ;ax = a
    mov bx, b   ;bx = b
    cmp bx, 0
    je divisionByZero
    idiv bx  ;ax = a / b

    mov bx, c   ;bx = c
    cmp bx, 0 ;0 + 2 =  - 8
    je divisionByZero
    idiv bx  ;ax = a / b / c 
    
    add ax, cx  ;ax = a / b / c + (c ^ 3 + b ^ 2) / d
    jo overflow

    jmp output

output proc

signTest:

    mov cx, ax
    lea dx, resultMessage
    mov ah, 09h
    int 21h
    mov ax, cx

    cmp ax, 0
    jns resultToStack

    mov cx, ax
    mov ah, 02h
    mov dl, '-'
    int 21h

    mov ax, cx
    neg ax

resultToStack:

    mov cx, 10

    mov dx, 0
    idiv cx

    add dl, '0'
    push dx

    inc count
    cmp ax, 0
    jnz resultToStack

resultOutput:
    
    pop dx
    mov ah, 02h
    int 21h

    dec count

    cmp count, 0
    jne resultOutput

    jmp exit
    
output endp

overflow:
    lea dx, overflowException
    mov ah, 09h
    int 21h
    jmp exit

divisionByZero:
    lea dx, divisionByZeroException
    mov ah, 09h
    int 21h
    jmp exit

invalidInput:
    lea dx, invalidInputException
    mov ah, 09h
    int 21h
    jmp exit

moreThen:
    lea dx, moreThenException
    mov ah, 09h
    int 21h
    jmp exit

lessThen:
    lea dx, lessThenException
    mov ah, 09h
    int 21h
    jmp exit

exit:
    mov ax, 4c00h
    mov al, 0
    int 21h

end start