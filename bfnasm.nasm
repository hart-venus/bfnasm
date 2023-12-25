section .data
    bufferSize equ 104857600 ; 100 MB
    tapeSize equ 30000 ; 30,000 cells
    noParamsMsg db "Usage: ./bfnasm <filename>", 10, 0
    noParamsMsgLen equ $ - noParamsMsg
    badFileMsg db "Error: could not open file", 10, 0
    badFileMsgLen equ $ - badFileMsg

    defFilename db "bfnasm/README.md", 0

section .bss 
    fd resq 1 ; file descriptor
    buffer resb bufferSize
    tape resb tapeSize
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

    ; save file descriptor
    mov [fd], rax
    
    ; dump file contents into buffer
    mov rax, 0
    mov rdi, [fd] ; file descriptor
    mov rsi, buffer
    mov rdx, bufferSize
    syscall

    ; close file
    mov rax, 3
    mov rdi, [fd]
    syscall

    lea rsi, buffer ; load address of buffer into rsi (our instruction pointer)
    lea rdi, tape ; load address of tape into rdi (our data pointer)
    readCycle:
        ; first, let's print the current value under the instruction pointer
        ;push rsi
        ;push rdi
        ;mov rax, 1
        ;mov rdi, 1
        ;mov rdx, 1
        ;syscall
        ;pop rdi
        ;pop rsi


        cmp byte [rsi], 0 ; check if we've reached the end of the file
        je exit
        cmp byte [rsi], '+' ; increment value at data pointer
        je plus
        cmp byte [rsi], '-' ; decrement value at data pointer
        je minus
        cmp byte [rsi], '>' ; increment data pointer
        je nextData
        cmp byte [rsi], '<' ; decrement data pointer
        je prevData
        cmp byte [rsi], '.' ; print value at data pointer
        je print
        cmp byte [rsi], '[' ; start loop
        je startLoop
        cmp byte [rsi], ']' ; end loop
        je endLoop
        ; if we didn't match any of the above, we can ignore the character
        jmp next

        plus:
            inc byte [rdi]
            jmp next
        minus:
            dec byte [rdi]
            jmp next
        nextData:
            inc rdi 
            ; check if we've reached the end of the tape
            cmp rdi, tape + tapeSize
            jne next
            ; if we've reached the end of the tape, we need to wrap around
            mov rdi, tape
            jmp next
        prevData:
            dec rdi
            ; check if we've reached the beginning of the tape
            cmp rdi, tape-1
            jne next
            ; if we've reached the beginning of the tape, we need to wrap around
            mov rdi, tape + tapeSize - 1
            jmp next
        print:
            push rsi 
            push rdi 
            
            mov rax, 1
            mov rsi, rdi
            mov rdi, 1
            mov rdx, 1
            syscall

            pop rdi 
            pop rsi 
            jmp next
        startLoop:
            push rsi ; save instruction pointer
            cmp byte [rdi], 0 ; check if value at data pointer is 0

            je goOutside ; if it's not 0, we can continue
            jmp next ; continue

            goOutside:
            ; if it is 0, we need to find the matching ] to get to it
            mov rcx, 1 ; counter for number of [ we've seen

            findEndLoop:
                inc rsi
                cmp byte [rsi], '['
                jne notNestedLoop
                nestedLoop:
                    inc rcx
                    jmp findEndLoop
                notNestedLoop: 
                    cmp byte [rsi], ']'
                    jne findEndLoop
                found:
                    dec rcx
                    cmp rcx, 0
                    jne findEndLoop
                    jmp readCycle

        endLoop:
            cmp byte [rdi], 0 ; check if value at data pointer is 0
            jne getOut ; if it is 0, we can continue

            pop rcx ; throw away instruction pointer
            jmp next ; continue

            getOut:
                ; if it's not 0, we need to find the matching [
                pop rsi ; restore instruction pointer
                jmp readCycle ; continue
        next:
            inc rsi
            jmp readCycle

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