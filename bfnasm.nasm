section .data
    noParamsMsg db "Usage: ./bfnasm <filename>", 10, 0
    noParamsMsgLen equ $ - noParamsMsg
section .bss 

section .text
    global _start

_start:
    ; check if there is a parameter by popping argc
    pop rax
    cmp rax, 1 ; there are no parameters besides the program name
    je noParams
    jmp exit

    noParams:
        push noParamsMsg
        push noParamsMsgLen
        call printWithLen
        mov eax, 60
        mov edi, 1 ; exit code 1
        syscall
    
    exit:
        mov eax, 60
        xor edi, edi ; exit code 0
        syscall 

printWithLen:
    ; takes in two parameters: pointer to string and length of string
    ; and prints the string using write syscall
    mov rsi, [rsp + 16]
    mov rdx, [rsp + 8]
    mov rax, 1
    mov edi, 1
    syscall
    ret