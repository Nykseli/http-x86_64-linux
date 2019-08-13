;;;
; Macros for string parsing (mainly the url)
;;

; parse the uri ignoring the first / character
%macro parse_uri 0
    mov rax, client_buffer ; http header
    mov rbx, 0 ; length of the uri
; first loop trough the request type and get to the first / char
%%_url_start_loop:
    inc rax
    mov cl, [rax]
    cmp cl, 47 ; cmp to / char
    jne %%_url_start_loop
; loop the uri until the space before the http version
; and save the chars to the request_uri buffer
%%_url_loop:
    inc rax
    mov cl, [rax]
    cmp cl, 32 ; comp to space
    je %%_url_loop_end
    mov rsi, request_uri
    add rsi, rbx
    mov [rsi], cl
    inc rbx
    jmp %%_url_loop
; save the length of the uri and null terminate it
%%_url_loop_end:
    mov [request_urilen], ebx
    mov rsi, request_uri
    add rsi, rbx
    mov cl, 0
    mov [rsi], cl
%endmacro
