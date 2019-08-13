;;;
; The main (_start) file
; Server listens 0.0.0.0:8888
;;

%include "src/linux-x86_64.asm"
%include "src/syscall-macro.asm"

; --------------------- DATA START ----------------------
section .data

    ; define null ternimated new line character for printing
    new_line db 10, 0

    ; int value 1 used to set the socket option to 1
    socketopt_1 dd 1

    ; this is the socket addr used to bind the socketfd to ipv4 tcp socket
    ; this is in network (little-endian) order
    ; first two is the AF_INET short,
    ; the second is the port short (8888)
    ; the rest is the addrres (0.0.0.0) (INADDR_ANY)
    ; this has size of 16 bytes
    socketaddr db 2, 0, 0x22, 0xb8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

    ;delay for sleep macro
    tv_delay dq 10, 500000000 ; x,y seconds

    ; debug message
    hello_user db "Hello user",10,0
; --------------------- DATA END ----------------------


; --------------------- BSS START ----------------------
section .bss

    ; 32 bits for the socket file descriptor
    socketfd resd 1

    ; 32 bits for the connection file descriptor
    conncetfd resd 1

    ; store 2kib for the http header
    client_buffer resb 2048
; --------------------- BSS END ------------------------

; --------------------- TEXT START ----------------------
section .text
    global _start
; --------------------- TEXT END ------------------------


_start:

    ; create the ipv4 tcp socket
    mov rax, SYS_SOCKET
    mov rdi, PF_INET
    mov rsi, SOCK_STREAM
    mov rdx, IPPROTO_TCP
    syscall

    ; check if the socket creation failed
    cmp rax, 0
    jl fail_program

    ; save the socketfd
    mov [socketfd], eax

    ; set option to trying to reuse the port
    mov rax, SYS_SETSOCKOPT
    mov rdi, [socketfd]
    mov rsi, SOL_SOCKET
    mov rdx, SO_REUSEADDR
    mov r10, socketopt_1
    mov r8, 4 ; socket opt is 4 bytes
    syscall

    ; check if the setoptsock was succesfull
    cmp rax, 0
    jl close_fail

    ; bind the socket
    mov rax, SYS_BIND
    mov rdi, [socketfd]
    mov rsi, socketaddr
    mov rdx, 16 ; length of the socketaddr
    syscall

    ; check if the bind was succesfull
    cmp rax, 0
    jl close_fail

    ; Prepare to listen the connection
    mov rax, SYS_LISTEN
    mov rdi, [socketfd]
    mov rsi, SOCK_BACKLOG
    syscall

    ; check if the listen was succesfull
    cmp rax, 0
    jl close_fail

    ; sleep so we can make sure with lsof -i tcp that the socket is up
    ; sleep

    ; Accept a single client request
    mov rax, SYS_ACCEPT
    mov rdi, [socketfd]
    mov rsi, 0
    mov rdx, 0
    syscall

    ; check if the accept was succesfull
    cmp rax, 0
    jl close_fail

    ; save the connection file descriptor
    mov [conncetfd], rax
    ; print message so we know that the user connecter
    print hello_user

    ; shutdown (close) the client connection
    mov rax, SYS_SHUTDOWN
    mov rdi, [conncetfd]
    mov rsi, SHUT_RDWR
    syscall


    ; close the socket
    close [socketfd]

    ; exit succesfully
    exit 0

; close the socket and exit the program with error code 2
close_fail:
    close [socketfd]
    exit 2

; fail with the error code 1
fail_program:
    exit 1
