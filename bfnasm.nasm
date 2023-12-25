section .data
    bufferSize equ 104857600 ; 100 MB
    noParamsMsg db "Usage: ./bfnasm <filename>", 10, 0
    noParamsMsgLen equ $ - noParamsMsg
    badFileMsg db "Error: could not open file", 10, 0
    badFileMsgLen equ $ - badFileMsg

    defFilename db "bfnasm/README.md", 0

section .bss 
    fd resq 1 ; file descriptor
    buffer resb bufferSize

section .text
    global _start

_start:
    ; check if there is a parameter by popping argc
    pop rax
    cmp rax, 1 ; there are no parameters besides the program name
    je noParams
    ; we know there's at least one parameter, so we can get argv
    mov rdi, [rsp + 8] ; get first param after program name
    mov rax, 2 ; open syscall
    mov rsi, 0 ; read only
    syscall

    cmp rax, 0 ; check if file opened successfully
    jl badFile

    jmp exit

    noParams:
        push noParamsMsg
        push noParamsMsgLen
        call printWithLen
        ; restore stack
        add rsp, 16
        mov eax, 60
        mov edi, 1 ; exit code 1
        syscall

    badFile:
        push badFileMsg
        push badFileMsgLen
        call printWithLen
        ; restore stack
        add rsp, 16
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