.model small        ;exe memory model
.stack 100h        ;stack 256 bytes
.code      
start:  
    mov ax,@data      ;data segment address 
    mov ds,ax        ;moves to ds
    
    mov dx,offset message  ;address of string in dx
    mov ah,9         
    int 21h        ;output of the string
        
    mov dl,07        ;007 ascii beep sound
    mov ah,2    
    int 21h 
    
    mov ax,4c00h
    int 21h        ;function end program
      
    .data         ;data segment
message db "home, sweet home!",0Dh,0Ah,'$' 
    end start 