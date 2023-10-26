.model	small
.stack	100h
.data
           
MaxArrayLength              equ 30            
            
ArrayLength                 dw  ?
InputArrayLengthMsgStr      db  'Input number of elements (0, 30]: $'
maxNull                     db  0Ah,0Dh,'Iinfinity.','$',0Ah,0Dh                                
ErrorInputMsgStr            db  0Ah,0Dh,'Incorrect value, try again.',0Ah,0Dh, '$' 
ErrorInputArrayLengthMsgStr db  0Ah,0Dh,'Array length should be in range (0,30].', '$'
                                                 
InputMsgStr                 db  0Ah, 0Dh,'Input element (-32 768..32 767) : $'    
CurrentEl                   db  2 dup(0)

Answer                      db  20 dup('$'), 0Ah,0Dh, '$'
                                
NumBuffer                   dw  0

NumLength                   db  7
EnterredNum                 db  9 dup('$')              

nextStr                     db  0Ah,0Dh,'$'       
ten                         dw  10
two                         dw  2	
precision                   db  5             
minus                       db  0  
Max                         dw  0
MaxTemp                     dw  0
Array                       dw  MaxArrayLength dup (0)
Temp                        dd  0
OutputArray                 dd  MaxArrayLength dup(0) 
                                
                              
.code      

start:                            
mov	ax,@data                      ;data segment address
mov	ds,ax                         ;moves to ds
                                  
xor	ax,ax                         ;ax = 0
                               
call inputMas                     ;array from user
call FindMax                      ;max element in array
call MakeNormal                   
                                  
inputMas proc                       
    call inputArrayLength         
    call inputArray                                     
    ret                           
endp     

inputArrayLength proc near
    mov cx, 1           
    inputArrayLengthLoop:
       call ShowInputArrayLengthMsg ;input array length message
       push cx                      
       call inputElementBuff        ;entrering the number of elements
       pop cx
       mov ArrayLength,ax           ;checking for (0;30] range
       cmp ArrayLength,0
       jle lengthError
       cmp ArrayLength,30
       jg  lengthError
                            
    loop inputArrayLengthLoop       ;while length is not correct 
    ret      
endp

lengthError:
    call ErrorInput                 ;display error message
    jmp  inputArrayLengthLoop       ;ask for input again
    
inputArray proc
    xor di,di                       ;di = 0
                                               
    mov cx,ArrayLength            
    inputArrayLoop:
       call ShowInputMsg            ;message with the range
       push cx                      
       call inputElementBuff        ;entering the element in buffer
       pop cx      
       
       mov Array[di], ax            ;new element in array

       add di,2                     
    loop inputArrayLoop           
    ret      
endp  



resetNumBuffer proc
    mov NumBuffer, 0                 ;reseting numBuffer due to some error
    ret
endp    

inputElementBuff proc                                     
    
    xor ax,ax                        ;ax = 0
    xor cx,cx                        ;cx = 0
    
    mov al,NumLength
    
    mov [EnterredNum],al
    mov [EnterredNum+1],0
    lea dx,EnterredNum               ;input of the number of elements 
    call input
    
    mov cl,[EnterredNum+1]
    lea si,EnterredNum
    add si,2
    
    xor ax,ax                        ;ax = 0
    xor bx,bx                        ;bx = 0
    xor dx,dx                        ;dx = 0
    mov dx,10        
    NextSym:                         ;for each character in the string
         xor ax,ax
         lodsb                       ;loads the byte addressed by si into al
         cmp bl,0
         je checkMinus
    
    checkSym:
         
         cmp al,'0'                  ;if 0 - 9, then convert to integer
         jl badNum
         cmp al,'9'
         jg badNum
         
         sub ax,'0'                 ;turn in integer
         mov bx,ax
         xor ax,ax
         mov ax,NumBuffer
         
         imul dx
         jo badNum                  ;if overflow
         cmp minus,1
         je doSub
         add ax, bx
         comeBack:
         jo badNum                  ;if overflow
         mov NumBuffer,ax
         mov bx,1
         mov dx,10
         
    loop NextSym 
    
    mov ax,NumBuffer
    mov minus,0
    
    
    finish: 
        call resetNumBuffer                        
        ret 
doSub:                                 ;subtraction
    sub ax,bx                          
    jmp comeBack       
checkMinus:
    inc bl
    cmp al, '-'
    
    je SetMinus
    
    jmp checkSym                       ;if there is no minus sign
                  
SetMinus:
    mov minus,1                        ;set flag in minus variable
    dec cx                             
    cmp cx,0
    je badNum
    jmp NextSym
    
badNum:
    clc
    mov minus,0                        ;reseting minus string
    call ErrorInput                    ;error input 
    call resetNumBuffer                ;reseting numBuffer
    jmp inputElementBuff                            
endp
     
input proc near
    mov ah,0Ah
    int 21h
    ret
input endp

ErrorInput proc                   
    lea dx, ErrorInputMsgStr      ;incorrect input message
    mov ah, 09h                   
    int 21h                       
    ret                           
endp                              
      

ShowInputArrayLengthMsg proc
    push ax
    push dx
      
    mov ah,09h                      
    lea dx, InputArrayLengthMsgStr  ;display array length message           
    int 21h  
    
    pop dx
    pop ax 
     
    ret
endp          
                                  
ShowInputMsg proc                     
    push ax
    push dx                     
                                  
    mov ah,09h                    
    lea dx, InputMsgStr             ;show input message
    int 21h   
    
    pop dx
    pop ax                    
    ret                           
endp                        
                                  
FindMax proc near
    xor di,di                       ;di = 0
                          
    mov cx, ArrayLength
    mov ax, Array[di]
    add di,2                        ;value part of array of numbers
    dec cx
    cmp cx,0
    je endFind                      ;if the end of the array
    find:
        cmp cx,0
        je endFind
        mov dx,Array[di]            ;comparing previous with a new one
        cmp ax,dx
        jl saveMax                  ;if prev is less
        add di,2
    loop find
    
    jmp endFind
    
    saveMax:
        mov ax,dx                   ;set current max value to ax
        add di,2
        dec cx
        
        jmp find    
    endFind:
    mov Max,ax
    mov MaxTemp,ax               
    ret                           
endp                              

MakeNormal proc near                
    cmp Max,0
    je  divNull                     ;infinity checking
    xor cx,cx
    mov cl,byte ptr [ArrayLength]   ;make a copy of value
    xor di,di                       ;di = 0
    xor si,si                       ;si = 0
    xor ax,ax                       ;ax = 0
    xor dx,dx                       ;dx = 0
    
    make:                           ;each number in array
        mov ax,MaxTemp
        mov Max,ax                  ;putting maxTemp in Max
        mov minus,0                 ;set no minus
        cmp cl,0
        je goEnd                    ;if the end of the array of numbers
        xor dx,dx
        mov ax, Array[si]
        xor ch,ch
        lea di,Answer
        cmp Max,0                   
        jg setZnak                  ;set znak
        cmp Max,0
        jl setPlus
        return2:
            mov [di],'+'            ;set + and go further
            inc di
    makeNum:                        ;making precision
        cmp ch,precision
        jg saveNum                  ;if precision is enough save and go to next
        mov bx,ax
        
        idiv Max                    ;divide ax by max
        
        cmp minus,0
        jne jump
        
        
        call makeMainPart
        cmp minus,1
        je incMinus
        
        jump:
        cmp ax,0
        je increase                 ;checks sign and 
        
        add al,'0'                  ;convert to ascii
        
        mov [di],al
        inc di
        
        mov ax,dx
        imul ten                    ;multiply by 10 for next digit
        inc ch                      ;current precision
        jmp makeNum
        
    incMinus:
        mov ax,dx
        mul ten                     ;multiply by 10 for next digit if minus
        inc minus
        jmp makeNum
            
    increase:        
        add al,'0'                  ;convert to ascii
                                    
        mov [di],al
        inc di
        
        cmp minus,0
        je firstSymbol              ;set point if not minus
        return:
        inc ch                 
        mov ax,bx
        imul ten                    ;move to next digit
        jmp makeNum
        
    saveNum:
        call output                 ;output final number
        add si,2                    
        jmp make                    ;make next number
        
    goEnd:
        mov ax,4c00h                ;exiting the programm
        int 21h    
    ret    
endp
    
makeMainPart proc near
    push dx
    push cx
    push bx                          
    xor cx,cx                        ;cx = 0

st: 
    xor dx,dx                        ;dx = 0
    idiv ten                         ;divide by ten
    cmp ax,0
    jnz go1                          ;if not zero
    cmp dx,0
    jnz go1
    jmp fin    
go1:
    inc cx
    push dx                          ;saving remainder
    jmp st
fin:

loop1:
    cmp cx,0                       ;if no main
    jz ifNoMainPart
    pop bx
    add bx,'0'                     ;convert to ascii
    mov  [di],bx                   ;set character
    inc di
loop loop1

mov [di],'.'
inc di
    
jmp fin2

ifNoMainPart:
    mov [di],'0'                   ;if no sign 
    inc di
    mov [di],'.'
    inc di
fin2:
    mov minus,1                    ;set minus and pop everything else
    pop bx
    pop cx
    pop dx        
    ret
endp
    
setPlus:                          
    push ax                       ;push array number in stack
    mov ax,Max
    mov bx,-1
    imul bx                       ;making Max positive 
    mov Max,ax
    pop ax
    imul bx                       ;making array value negative positive
    jmp return2                   ;set +

setZnak:                          
    cmp ax,0                      ;value from array
    jge return2                   ;set + if max and array numbers are greater than 0
    mov [di],'-'                  ;otherwise set -
    inc di
    mov bx,-1
    imul bx                       ;making array value negative
    jmp makeNum
       
firstSymbol:                      ;set point and minus
    mov al,'.'
    mov [di],al
    inc di
    mov minus,1
    jmp return
        
output proc
    lea dx,nextStr                ;enter
    mov ah,09h
    int 21h                       
    lea dx, Answer                ;final number output
    mov ah,09h
    int 21h
    dec cl                
    ret                           
endp                              
divNull:                          ;division by 0 is not legal
    lea dx,maxNull                ;display infinity message
    mov ah,09h
    int 21h
    mov ax,4c00h                  ;finishing programm
    int 21h    
    ret                                
end	start                         