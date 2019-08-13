;;;
; Macros for system calls
;;

; Exit with an error code (exit 0 succesfull)
%macro exit 1
    mov rax, SYS_EXIT
    mov rdi, %1
    syscall
%endmacro

; close a opened file
%macro close 1
    mov rax, SYS_CLOSE
    mov rdi, %1
    syscall;
%endmacro

; macro for sleeping
; legth is defined by tv_data in .data section
%macro sleep 0
    mov rax, SYS_NANOSLEEP
    mov rdi, tv_delay
    mov rsi, 0 ; the second argument is usually 0 according to the documentation
    syscall
%endmacro

; Print null terminated string
%macro print 1
    mov rax, %1 ; rax char pointer
    mov rsi, rax ; save the pointer to rsi. rsi holds the char* buffer argument in syscall
    mov rbx, 0 ; rbx str len
; calculate the length of the string
%%len_loop:
    mov cl, [rax] ; get one char at the time. moving to rcx would move 8 characters
    cmp cl, 0
    je %%print_loop_end
    inc rax
    inc rbx
    jmp %%len_loop
; finally print the text
%%print_loop_end:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    ; rsi holds the char pointer since it was saved there at start of print
    mov rdx, rbx
    syscall
%endmacro

; send to socket. arg 1 connection fd, arg 2 msg, arg 3 msg len
%macro send_to_sock 3
    mov rax, SYS_SENDTO
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, 0 ; no flags
    mov r8, 0 ; no sockaddr
    mov r9, 0 ; no sockaddrlen
    syscall
%endmacro

; send 404 header to connectionfd
%macro http_404 1
    send_to_sock %1, httpmsg_404, 40
    send_to_sock %1, server_name, 36
    send_to_sock %1, httpcnt_html, 40
    send_to_sock %1, httpmsg_end, 2
%endmacro
