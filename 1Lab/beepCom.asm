; beep.asm
.model tiny 
.code
org 100h
start:  

    mov ah,9 
    mov dx,offset message
    int 21h   
    
    mov ah,2
    mov dl,07  ;beep sound
    int 21h
     
    ret 
message db "home, sweet home!",0Dh,0Ah,'$' 
    end start 