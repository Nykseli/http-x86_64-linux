;;;
; The main (_start) file
; Server listens 0.0.0.0:8888
;;

%include "src/linux-x86_64.asm"
%include "src/syscall-macro.asm"

; --------------------- DATA START ----------------------
section .data
    ; server name len is 36
    server_name db "Server: linux-x86_64 httpasm/0.0.1",13,10
    ; message for 404, len 24
    httpmsg_404 db "HTTP/1.0 404 Not Found",13,10
    ; message for 200, len 17
    httpmsg_200 db "HTTP/1.0 200 OK",13,10
    ; message for html content, len 40
    httpcnt_html db "Content-Type: text/html",59," charset=utf-8",13,10
    ; message for css content , len 24
    httpcnt_css db "Content-Type: text/css",13,10
    ; message for js content, len 31
    httpcnt_js db "Content-Type: text/javascript",13,10
    ; the last newline for the end of the message, len 2
    httpmsg_end db 13, 10 ; (\r\n)

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
    connectfd resd 1

    ; store 2kib for the http header
    client_buffer resb 2048

    ; also have 32 bits for the length of the header
    client_bufferlen resd 1
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
    mov [connectfd], eax
    ; print message so we know that the user connecter
    print hello_user

    ; get the message from user (http header)
    mov rax, SYS_RECVFROM
    mov rdi, [connectfd]
    mov rsi, client_buffer
    mov rdx, 2047 ; this makes sure that the client buffer is null terminated
    mov r10, 0 ; no flags
    mov r8, 0 ; we don't the socketaddr
    mov r9, 0 ; we also don't the socketaddrlen
    syscall

    ; check if the read was succesfull
    cmp rax, 0
    jl close_fail

    ; save the length of the buffer
    mov [client_bufferlen], eax

    print client_buffer
    print new_line

    ; response with 404 for now
    http_404 [connectfd]

    ; shutdown (close) the client connection
    mov rax, SYS_SHUTDOWN
    mov rdi, [connectfd]
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
