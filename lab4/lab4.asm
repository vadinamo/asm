;С клавиатуры вводится строка. Необходимо посчитать и вывести на экран, сколько раз в этой строке встречается каждая из согласных букв.

.model small
.stack 100h

.data  
    string db 100 dup(?)

    lowerCase db 'bcdfghjklmnpqrstvwxz$'
    upperCase db 'BCDFGHJKLMNPQRSTVWXZ$'

    startMessage db 'Enter your string:', 10, '$'
    outputMessage db 'Number of consonants in your string:', 10, '$'
    emptyException db 'String is empty!', 10, '$'
    output db 0dh, 0ah, ' : $'

    count dw 0

.code

start:        
    mov ax, @data
    mov ds, ax
    mov es, ax

startFunc:
    mov ah, 9
    lea dx, startMessage
    int 21h
        
    lea di, string
    mov ah, 1

inputFunc:
    int 21h
    cmp al, 0dh ;проверка на нажатие ввод
    je stopInput

    mov [si], al
    inc si

    stosb
    jmp inputFunc
        
stopInput:
    mov al, "$" ;добавение $ в конец строки
    stosb
            
    cmp si, 0
    je emptyString
    
    mov bx, 0 ;номер в введенной строке
    mov si, 0 ;номер в строках согласных

    mov ah, 9
    lea dx, outputMessage
    int 21h
        
totalCount:
    mov al, string[bx] ;помещение в al символа строки под номером bx
    cmp al, "$"
    je nextLetter

    cmp al, lowerCase[si]
    je isConsonant

    cmp al, upperCase[si]
    je isConsonant
            
    inc bx
    jmp totalCount
        
isConsonant:
    mov cx, count
    inc cx

    mov count, cx
    inc bx 

    jmp totalCount     
            
nextLetter:
    cmp count, 0
    je skip ;если согласной нет - пропуск

    mov ah, 9
    mov dl, lowerCase[si]
    mov output[2], dl
    lea dx, output ;вывод результата по согласной
    int 21h
            
    mov ah, 2
    mov dx, count
    add dx, 30h ;перевод из char в int
    int 21h

skip:
    inc si
    cmp lowerCase[si], "$"
    je exit

    mov count, 0
    mov bx, 0

    jmp totalCount

emptyString:
    mov ah, 9
    lea dx, emptyException
    int 21h

exit:
    mov ah, 4ch
    int 21h

end start