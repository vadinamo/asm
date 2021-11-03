;Если a * (c + b) * (d ^ 2) = (a – d) * (b + c) то
;      Если a > b ^ 2 то
;        Результат = c ^ 2 /(d - c) - d ^ 2
;      Иначе
;        Если a < c + d то
;            Результат = d ^ 2 + (b OR c)
;        Иначе
;            Результат = a + (b AND c)


;A 16-bit integer can store 216 (or 65,536) distinct values.
;In an unsigned representation, these values are the integers between 0 and 65,535
;using two's complement, possible values range from −32,768 to 32,767.

.model small
.stack 256

.data
greetings db 10,'Hello!',13,10,10,'$'
space db 10,'$'

wrongInput db 10,'ERROR! WRONG INPUT! TERMINATING THE PROGRAM!',13,10,'$'
overFlow db 10,'ERROR! OVERFLOW! TERMINATING THE PROGRAM!',13,10,'$'
divisionByZero db 10,'ERROR! DIVISION BY ZERO! TERMINATING THE PROGRAM!',13,10,'$'

enterA db 'Enter a:  $'
enterB db 'Enter b:  $'
enterC db 'Enter c:  $'
enterDq db 'Enter d:  $'

output db 10,'Result, which stored in ax is: ',13,10,'$'

a dw 0
b dw 0
c dw 0
d dw 0

aEntered dw 0
bEntered dw 0
cEntered dw 0
dEntered dw 0

minus dw 0
zero dw 0
counter dw 0

.code
.386

main:   

    mov ax, @data
    mov ds, ax

greetingsFunc:

    lea dx, greetings
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

enterAFunc:

    lea dx, enterA
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

    jmp handleFirstNum

enterBFunc:

    lea dx, enterB
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

    jmp handleFirstNum

enterCFunc:

    lea dx, enterC
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

    jmp handleFirstNum

enterDFunc:

    lea dx, enterDq
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

    jmp handleFirstNum

handleFirstNum:

    mov ah, 01h
    int 21h      ; al - first symbol

    cmp al, 2dh  ; if '-'
    je minusLabel

    cmp al, 30h  ; if 0 - handle next var
    je firstIsZero

    cmp al, 30h  ; 30h - 0 in decimal
    jl wrongInputLabel
    cmp al, 39h  ; 39h - 9 in decimal
    jg wrongInputLabel
    
    sub al, 30h  ; now al - first number (30h - 'ascii 0')
    mov ah, 0    ; extend to word

    mov bx, 10   ; if more than one digit (input 12 == (1 * 10) + 2)
    mov cx, ax   ; cx - first num
    jmp loopLabel

minusLabel:

    mov minus, 1
    jmp handleFirstNum

loopLabel: 

    mov ah, 01h
    int 21h      ; al - next symbol

    cmp al, 0dh  ; cmp with 'enter button'
    je endLoop   ; if 'enter button' pressed - return

    cmp al, 30h  ; 30h - 1 in decimal
    jl wrongInputLabel
    cmp al, 39h  ; 39h - 9 in decimal
    jg wrongInputLabel

    sub al, 30h  ; al - next number
    cbw          ; extend to word

    xchg ax, cx  ; now cx - next number, ax - previous

    mul bx       ; ax * 10
    jo overflowLabel

    add cx, ax   ; cx = (ax * 10) + cx
    jc overflowLabel ; jc instead jo

    cmp cx, 0
    je overflowLabel

    jmp loopLabel; continue input

firstIsZero:

    mov zero, 1
    mov cx, 0

    lea dx, space
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

    jmp endLoopA

endLoop:   

    cmp minus, 1 ; 1 means that number with minus
    jne endLoopA
    neg cx

endLoopA:

    cmp aEntered, 0
    jne endLoopB
    mov a, cx
    mov aEntered, 1
    mov minus, 0
    mov zero, 0
    jmp enterBFunc

endLoopB:

    cmp bEntered, 0
    jne endLoopC
    mov b, cx
    mov bEntered, 1
    mov minus, 0
    mov zero, 0
    jmp enterCFunc

endLoopC:

    cmp cEntered, 0
    jne endLoopD
    mov c, cx
    mov cEntered, 1
    mov minus, 0
    mov zero, 0
    jmp enterDFunc

endLoopD:

    cmp dEntered, 0
    jne leftPart
    mov d, cx
    mov dEntered, 1
    mov minus, 0
    mov zero, 0

    ;mov ax, 17
    ;jmp loophere

testValues:

    mov ax, a
    mov bx, b
    mov cx, c
    mov dx, d

leftPart:

    mov ax, a

    mov bx, b
    add bx, c
    jo overflowLabel
    
    mul bx    ; ax = ax * bx
    jo overflowLabel

    mov bx, ax

    mov ax, d
    mul ax    ; ax = ax ^ 2
    jo overflowLabel

    mul bx    ; ax = ax * bx 
    jo overflowLabel

    mov bx, ax ; bx = a * (c + b) * (d ^ 2) leftPart
    mov ax, 0

rightPart:

    mov ax, a
    sub ax, d
    jo overflowLabel

    mov cx, b
    add cx, c
    jo overflowLabel

    mul cx     ; ax = ax * cx
    jo overflowLabel

    mov cx, ax ; cx = (a – d) * (b + c) rightPart
    mov ax, 0

compareLeftAndRight:

    cmp cx, bx
    jne secondIf


firstIf:       ; a > b ^ 2

    mov bx, a

    mov ax, b
    mul ax     ; ax = ax ^ 2
    jo overflowLabel 

    cmp bx, ax ; bx = a, ax = b ^ 2
    jl secondIf


firstSolution:  ; c ^ 2 / (d - c) - d ^ 2

    mov ax, c
    mul ax      ; ax = c ^ 2
    jo overflowLabel
    
    mov bx, d
    sub bx, c   ; bx = d - c 
    jo overflowLabel

    cmp bx, 0 
    je divisionByZeroLabel     ; if denominator = 0 => exit (exception)
  
    div bx      ; ax = ax / bx
    jo overflowLabel

    mov bx, ax  ; bx = c ^ 2 / (d - c)

    mov ax, d
    mul ax
    jo overflowLabel

    sub bx, ax  ; bx = c ^ 2 / (d - c) - d ^ 2
    jo overflowLabel

    mov ax, bx

    jmp putResultOnStack

secondIf:      ; a < c + d
    mov ax, a

    mov bx, c
    add bx, d
    jo overflowLabel

    cmp ax, bx
    jg thirdSolution



secondSolution: ; d ^ 2 + (b OR c)
    
    mov ax, b
    mov bx, c

    or ax, bx   ; puts 'or' result in ax
    jo overflowLabel

    mov bx, ax  ; then in bx

    mov ax, d
    mul ax
    jo overflowLabel

    add ax, bx
    jo overflowLabel

    jmp putResultOnStack

thirdSolution:   ; a + (b AND c)

    mov ax, b
    mov bx, c

    and ax, bx
    jo overflowLabel

    mov bx, ax

    mov ax, a

    add ax, bx
    jo overflowLabel

    jmp putResultOnStack

putResultOnStack:

    mov cx, 10

    mov dx, 0
    div cx

    add dl, '0'
    push dx

    inc counter

    cmp ax, 0

    jnz putResultOnStack

startOutput:

    lea dx, output
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

popResultFromStack:
     
    pop dx

    mov ah, 02h  ; 02h is the function number of output char
    int 21h 
    dec counter

    cmp counter, 0
    jne popResultFromStack

    jmp exit

overflowLabel:

    lea dx, overFlow
    mov ah, 09h  ; display string, which is stored in dx
    int 21h
    jmp exit

wrongInputLabel:

    lea dx, wrongInput
    mov ah, 09h  ; display string, which is stored in dx
    int 21h
    jmp exit

divisionByZeroLabel:

    lea dx, divisionByZero
    mov ah, 09h  ; display string, which is stored in dx
    int 21h
    jmp exit

exit:

    lea dx, space
    mov ah, 09h  ; display string, which is stored in dx
    int 21h

    mov ax, 4c00h
    mov al, 0
    int 21h
    
end main