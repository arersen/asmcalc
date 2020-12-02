.model small
.stack 100h
 
data segment      
   _errorCF db 'Finded overflow at ADD operation!','$'  
   _errorOF db 'Finded overflow at SUB operation!','$'             
   _INFO    db 'Types of operations:',10,13,'1. + -> sum',10,13,'2. - -> subtraction',10,13,'$'           
   _nc      db 10,13,'$'
   first    dw 65535    ;first operand
   second   dw 5         ;second operand
data ends
   
code segment
assume cs:code,ds:data     
begin:
        mov ax,data         
        mov ds,ax           
        mov es,ax           ;es refers to the same place as ds
;------------------------------------------------
;Displaying a prompt to enter a number
        mov ah,09h          ;command to output a line
        mov dx,offset _INFO ;line offset
        int 21h             ;execute command
;------------------------------------------------
;Determine the type of operation
enter_type_operation: 
        mov ah,01h            ;calling a command to enter a character from the keyboard
        int 21h               ;execute command
        cmp al,'+'            ;introduced "+" 
        je summ               ;yes -> summing 2 numbers
        cmp al,'-'            ;introduced "-" 
        je minus              ;yes -> subtract 2 numbers
        jmp enter_type_operation ;in all other cases - repeat input
;------------------------------------------------
;Summing 2 numbers
summ:
        mov ah,09h            ;command to output a line
        mov dx,offset _nc     ;in dx offsets per line
        int 21h               ;execute command
        mov ax,first          ;ax=first
        mov bx,second 
        add ax,bx             ;ax=ax+bx
        jnc write_res         ;if there is no carry (CF = 0), then the output of the result
        jmp errorCF           ;otherwise, output an error
;------------------------------------------------
minus:
        mov ah,09h            ;команда на вывод строки
        mov dx,offset _nc     ;в dx смещение на строку
        int 21h               ;выполнить команду
        mov ax,first          ;ax=first 
        mov bx,second
        sub ax,bx             ;ax=ax-bx
        jno write_res         ;если нет заема(OF=0), то вывод результата
        jmp errorOF           ;иначе вывести ошибку
;------------------------------------------------
;Subtract of number
write_res:
        test ax,ax            ;проверим знак числа
        jns init              ;SF=0? если да, то просто вывод числа
        mov cx,ax             ;иначе выводим как отрицательное, cx=ax
        mov ah,02h            ;выводим символ
        mov dl,'-'            ;поместим в dl символ минуса
        int 21h               ;выполним команду
        mov ax,cx             ;вернем старое значение, cx=ax
        neg ax                ;сменим знак операнда     
init:
        xor cx,cx             ;cx=0
        xor dx,dx             ;dx=0
    push -1               ;сохраним признак конца числа
    mov cx,10         ;делим на 10
repeat: 
        xor dx,dx         ;очистим регистр dx
    div cx                ;делим 
    push dx               ;сохраним цифру
    cmp ax,0          ;остался 0? (оптимальнее or ax,ax)
    jne repeat        ;нет -> продолжим
    mov ah,2h             ;вывод символа
digit:  
        pop dx                ;восстановим цифру
    cmp dx,-1         ;дошли до конца -> выход {оптимальнее: or dx,dx jl ex}
    je exit               ;завершить вывод
    add dl,'0'        ;преобразуем число в цифру
    int 21h               ;выведем цифру на экран
    jmp digit         ;и продолжим 
;------------------------------------------------
;Overflow error output during addition operation
errorCF:
        mov ah,09h            ;команда на вывод строки
        mov dx,offset _errorCF;в dx смещение на строку
        int 21h               ;выполнить команду
        jmp exit              ;переход по метке
;------------------------------------------------
;Loan error output when subtracting      
errorOF:
        mov ah,09h            ;команда на вывод строки
        mov dx,offset _errorOF;в dx смещение на строку
        int 21h               ;выполнить команду
        jmp exit              ;переход по метке
;------------------------------------------------ 
exit:
        mov ax,4c00h       
        int 21h
code ends
end begin
