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
        mov ah,09h            ;command to output a line
        mov dx,offset _nc     ;in dx offsets per line
        int 21h               ;execute command
        mov ax,first          ;ax=first 
        mov bx,second
        sub ax,bx             ;ax=ax-bx
        jno write_res         ;if there is no carry(OF=0), then the output of the result
        jmp errorOF           ;otherwise,output an error
;------------------------------------------------
;Subtract of number
write_res:
        test ax,ax            ;check the sign of the number
        jns init              ;SF=0? if yes, then the output of the result
        mov cx,ax             ;otherwise we output as negative, cx = ax
        mov ah,02h            ;display the symbol
        mov dl,'-'            ;put a minus symbol in dl
        int 21h               ;execute command
        mov ax,cx             ;return the old value, cx = ax
        neg ax                ;change the sign of the operand    
init:
        xor cx,cx             ;cx=0
        xor dx,dx             ;dx=0
    push -1               ;keep the end-of-number sign
    mov cx,10         ;division by 10
repeat: 
        xor dx,dx         ;clear registr dx
    div cx                ;division
    push dx               ;save number
    cmp ax,0          ;left 0? (more optimal or ax, ax)
    jne repeat        ;no -> continue
    mov ah,2h             ;output symbol
digit:  
        pop dx                ;restore the figure
    cmp dx,-1         ;reached the end -> exit {optimal: or dx, dx jl ex}
    je exit               ;finish output
    add dl,'0'        ;convert number to digit
    int 21h               ;output digit to display
    jmp digit         ;and continue
;------------------------------------------------
;Overflow error output during addition operation
errorCF:
        mov ah,09h            ;command to output a line
        mov dx,offset _errorCF;in dx offset by line
        int 21h               ;execute command
        jmp exit              ;jump by label
;------------------------------------------------
;Loan error output when subtracting      
errorOF:
        mov ah,09h            ;command to output a line
        mov dx,offset _errorOF;in dx offset by line
        int 21h               ;execute command
        jmp exit              ;jump by label
;------------------------------------------------ 
exit:
        mov ax,4c00h       
        int 21h
code ends
end begin
