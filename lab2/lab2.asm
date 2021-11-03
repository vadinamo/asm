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
divisionByZeroException db 10,'Division by zero exception!',10,10,'$'
result db 10,'Result is : $'

a dw 0
b dw 0
c dw 0
d dw 0
count dw 0

enteredA dw 0
enteredB dw 0
enteredC dw 0
enteredD dw 0

negative dw 0

.code
.386

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

input:
    mov ah, 01h
    int 21h

    cmp al, 2dh
    je isNegative

    sub al, 30h
    mov ah, 0

    mov bx, 10
    mov cx, ax

    jmp inputLoop

isNegative:
    mov negative, 1
    jmp input

inputLoop:
    mov ah, 01h
    int 21h

    cmp al, 0dh
    je endInputLoop

    sub al, 30h
    cbw

    xchg ax, cx

    mul bx
    jo overflow

    add cx, ax
    jc overflow

    cmp cx, 0
    je overflow

    jmp inputLoop

endInputLoop:
    cmp negative, 1
    jne endAInput
    neg cx

endAInput:
    cmp enteredA, 0
    jne endBInput
    mov a, cx
    mov enteredA, 1
    mov negative, 0
    jmp bEnter

endBInput:
    cmp enteredB, 0
    jne endCInput
    mov b, cx
    mov enteredB, 1
    mov negative, 0
    jmp cEnter

endCInput:
    cmp enteredC, 0
    jne endDInput
    mov c, cx
    mov enteredC, 1
    mov negative, 0
    jmp dEnter

endDInput:
    cmp enteredD, 0
    jne firstIf
    mov d, cx
    mov enteredD, 1
    mov negative, 0

firstIf: ;a = c ^ 2
    mov ax, c   ;ax = c
    mul ax  ;ax = c ^ 2
    jo overflow
    mov cx, ax  ;cx = c ^ 2

    mov ax, a   ;ax = a

    cmp ax, cx
    jne secondIf

firstResult:    ;Результат = с / (a * b) + d
    mov ax, a   ;ax = a
    mov bx, b   ;bx = b
    mov cx, d   ;cx = d

    mul bx  ;ax = a * b
    jo overflow
    mov bx, ax  ;bx = a * b
    cmp bx, 0
    je divisionByZero
    mov ax, c   ;ax = c

    div bx  ;ax = c / (a * b)
    add ax, cx  ;ax = c / (a * b) + d
    jo overflow

    jmp resultToStack

secondIf:   ;c - b <> a ^ 2 + b ^ 3
    mov ax, a   ;ax = a
    mul ax  ;ax = a ^ 2
    jo overflow
    mov cx, ax  ;cx = a ^ 2

    mov bx, b   ;bx = b
    mov ax, b   ;ax = b
    mul ax  ;ax = b ^ 2
    jo overflow
    mul bx  ;ax = b ^ 3
    jo overflow
    add ax, cx  ;ax = a ^ 2 + b ^ 3
    jo overflow

    mov bx, c   ;bx = c
    mov cx, d   ;cx = d
    sub bx, cx  ;bx = c - d

    cmp ax, bx
    je thirdResult

secondResult:   ;Результат = a AND (b - c)
    mov ax, a   ;ax = a
    mov bx, b   ;bx = b

    sub bx, c   ;bx = b - c
    and ax, bx  ;ax = a AND (b - c)
    jo overflow

    jmp resultToStack

thirdResult:    ;Результат = a/b/c+(b^2+c^3)/d
    mov ax, b   ;ax = b
    mul ax  ;ax = b ^ 2
    jo overflow

    mov bx, ax  ;bx = b ^ 2
    mov ax, c   ;ax = c
    mov cx, c   ;cx = c

    mul ax  ;ax = c ^ 2
    jo overflow
    mul cx  ;ax = c ^ 3
    jo overflow
    add ax, bx  ;ax = c ^ 3 + b ^ 2
    jo overflow
    mov bx, d   ;bx = d
    cmp bx, 0
    je divisionByZero
    div bx  ;ax = (c ^ 3 + b ^ 2) / d
    mov cx, ax  ;cx = (c ^ 3 + b ^ 2) / d

    mov ax, a   ;ax = a
    mov bx, b   ;bx = b
    cmp bx, 0
    je divisionByZero
    div bx  ;ax = a / b

    mov bx, c   ;bx = c
    cmp bx, 0
    je divisionByZero
    div bx  ;ax = a / b / c
    
    add ax, cx  ;ax = a / b / c + (c ^ 3 + b ^ 2) / d
    jo overflow

    jmp resultToStack

resultToStack:
    mov cx, 10
    mov dx, 0
    div cx

    add dl, '0'
    push dx

    inc count

    cmp ax, 0
    jnz resultToStack

outputFunc:
    lea dx, result
    mov ah, 09h
    int 21h

resultOutput:
    pop dx

    mov ah, 02h
    int 21h

    dec count

    cmp count, 0
    jne resultOutput

    jmp exit

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

exit:
    mov ax, 4c00h
    mov al, 0
    int 21h

end start