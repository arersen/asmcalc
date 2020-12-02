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
        mov ah,01h            ;вызов команды ввода символа с клавиатуры
        int 21h               ;выполнить команду
        cmp al,'+'            ;введен "+" 
        je summ               ;да -> суммируем 2 числа
        cmp al,'-'            ;введен "-" 
        je minus              ;да -> вычитаем 2 числа
        jmp enter_type_operation;во всех других случаях - повтор ввода
;------------------------------------------------
;Суммирование двух чисел
summ:
        mov ah,09h            ;команда на вывод строки
        mov dx,offset _nc     ;в dx смещение на строку
        int 21h               ;выполнить команду
        mov ax,first          ;ax=first
        mov bx,second
        add ax,bx             ;ax=ax+bx
        jnc write_res         ;если нет переноса(CF=0), то вывод результата
        jmp errorCF           ;иначе вывести ошибку
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
;Вывод числа
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
;Вывод ошибки о переполнении, при операции сложения
errorCF:
        mov ah,09h            ;команда на вывод строки
        mov dx,offset _errorCF;в dx смещение на строку
        int 21h               ;выполнить команду
        jmp exit              ;переход по метке
;------------------------------------------------
;Вывод ошибки о заеме, при операции вычитания       
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
