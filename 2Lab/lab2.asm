.model small
.stack 100h

.data  
    
    size equ 200
    string db size dup ('$')
    slovo db size dup ('$')
    
    str1 db "Enter the string: $"
    str2 db "Entered string: $"
    str3 db "Enter the word: $"
    str4 db "Entered word: $"
    str5 db "Word not found.$"
    str6 db "String is empty$"
    str7 db "Word is empty$"
    str8 db "Word found.$"
    str9 db "It's the first word$"
    close db "Finishing the program.",0Dh,0Ah,'$'
    result db "Final string: $"
    enter db 0Dh,0Ah,'$'

.code

Output_string proc
    mov ah,9                 ;display string
    int 21h                 
    ret
Output_string endp

Output proc
    cmp bx[si], 0Dh          ;carriage return checking
    Output_sumb bx[si]
    inc si
    cmp bx[si], 0Dh
    jne call Output          ;display characters until carriage return
    ret
endp

Output_sumb macro symb
    mov dl,symb
    mov ah,06h               ;symbol direct console output
    int 21h
endm
                
Input_string macro str
    lea dx,str
    mov offset str,size
    mov ah,0Ah               ;read to bufer from stdin
    int 21h
endm

Exit proc
    mov dx,offset enter      ;new line
    call Output_string
    mov dx,offset result     ;final string
    call Output_string
    mov bx,offset string     ;user string
    mov si,2
    call Output
    mov dx,offset enter      ;new line
    call Output_string
    mov dx,offset close      ;finishing the program message
    call Output_string
    mov ax,4C00h             ;finishing the program
    int 21h
    ret
Exit endp

Empty_exit proc
    mov dx,offset enter      ;new line
    call Output_string
    mov dx,offset close      ;finishing the program message
    call Output_string
    mov ax,4C00h             ;finishing the program
    int 21h
    ret
Empty_exit endp

Counter proc
    inc ah                   ;increasing ah
    ret
Counter endp

Moove proc                   ;moving in string or word
    dec si
    cmp si,offset string[1] 
    je call Counter
    cmp [si],' '
    jne call Check_is_tab
    cmp [si],09h
    jne call Check_is_space 
    ret
Moove endp

Check_is_space proc
    cmp [si],' '             ;check for space
    jne call Moove
    ret    
Check_is_space endp

Check_is_tab proc            ;check for tab
    cmp [si],09h
    jne call Moove           
    ret    
Check_is_tab endp

Moove_space proc             ;from space to space
    dec si
    cmp si,offset string[1] 
    je call Counter          ;increase ah if 
    cmp [si],' '
    je call Moove_space      ;again if there is space
    cmp [si],09h
    je call Moove_space      ;again if there is tab
    ret                      
Moove_space endp

Delete proc 
    inc si
    mov dl,[si]
    dec si
    mov [si],dl                 ;exchanging nearest elements
    inc si                      ;latest element
    cmp [si],0Dh
    jne call Delete             ;deleting until there is no carriage return
    mov si,bx                   ;current position
    cmp [si],' '
    jne call Check_2
    ret
Delete endp
                                
Check_2 proc                    
    cmp [si],09h                ;checking for the end of the line
    jne call Delete
    ret
Check_2 endp
                
start:  
    mov ax,@data                ;data segment address  
    mov ds,ax                   ;moves to ds
    mov dx,offset str1          
    call Output_string          ;initital string
    Input_string string         ;initial string input
    
    mov dx,offset enter         ;new line
    call Output_string
    mov dx,offset str3          ;user word
    call Output_string          ;user word input
    Input_string slovo
    
    cmp string[1],0             
    je isEmpty                  ;if string is empty
    
    mov dx,offset enter
    call Output_string          ;new line
    mov dx,offset str2          ;entered string
    call Output_string
    mov bx,offset string
    mov si,2
    call Output                 ;user's entered string
    
    cmp slovo[1],0
    je isEmpty                  ;if word is empty
    
    mov dx,offset enter         ;new line
    call Output_string              
    mov dx,offset str4          ;entered word
    call Output_string
    mov bx,offset slovo
    mov si,2
    call Output                 ;user's entered word
    
isEmpty:
    mov ah,[string[1]]
    cmp ah,0
    je String_is_empty          ;if string is empty
    mov ah,[slovo[1]]
    cmp ah,0
    je Slovo_is_empty           ;if word is empty
    jne Find                    ;find word
    
String_is_empty:
    Output_sumb 0Dh             ;end of the line
    Output_sumb 0Ah
    mov dx,offset str6
    call Output_string          ;string is empty
    call Empty_exit
    
Slovo_is_empty:
    Output_sumb 0Dh             ;end of the line
    Output_sumb 0Ah
    mov dx,offset str7
    call Output_string          ;word is empty
    call Empty_exit
    
Find:
    mov si,offset string[1]
    mov di,offset slovo[2]
    jmp Find_symbol

Find_symbol:
    inc si
    cmp [si],0Dh
    je notFound                 ;not found if carraige return
    mov dl,[si]
    cmp [si],' '
    je Find_symbol              ;up until the space
    cmp [si],09h
    je Find_symbol              ;if there is tab
    cmp dl,0Dh
    je call Exit                ;exit if carriage return in string
    cmp dl,[di]
    jne Skip_slovo
    jmp Find_slovo
loop Find_symbol
    
Skip_slovo:
    cmp [si],' '
    je Find_symbol             ;find symb if space
    cmp [si],09h
    je Find_symbol             ;find symb if tab
    cmp [si],0Dh
    je notFound                ;word is not found if carriage return
    inc si
loop Skip_slovo     
    
Find_slovo:
    inc si
    inc di
    cmp [di],0Dh
    je isEnd                   ;end if carraige return
    mov dl,[si]
    cmp dl,[di]
    je loop Find_slovo
    jmp isStart 
    
isEnd:
    cmp [si],' '                
    je Found                   ;+1 if space
    cmp [si],09h
    je Found                   ;+1 if tab
    cmp [si],0Dh
    je Found                   ;+1 if carriage return
    
isStart:
    mov di,offset slovo[2]
    jmp Skip_slovo             

notFound:
    mov dx,offset enter         ;new line
    call Output_string          
    mov dx,offset str5
    call Output_string          ;not found message
    call Exit
        
Found:
    inc si
    mov dx,offset enter         ;new line
    call Output_string
    mov dx,offset str8
    call Output_string          ;found message
    jmp Delete_slovo            ;delete word
    
Delete_slovo:
    mov ah,0
    call Moove_space
    call Moove
    cmp ah,1
    je call Exit                ;end of the program if flag
    call Moove_space
    cmp ah,1
    je call Exit                ;end of the program if flag
    call Moove
    mov bx,si
    call Delete                 ;delete 
    call Exit                   ;end of the program
    
end start