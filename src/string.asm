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

; compare n bytes between str1 and 2, rax == 1 if equal rax == 0 if not
; args: str1, str2, str1len, str2len
%macro strncmp 4
%%_strncmp:
    mov r9,  %3 ; r9 is length 1
    mov r10, %4 ; r10 is length 2
    mov rax, %1 ; rax contains the str1
    mov rbx, %2 ; rbx contains the str2
    ; if strings are different length, they cannot be the same length
    cmp r9, r10
    jne %%_strncmp_false
    mov r10, 0
%%_strncmp_loop:
    mov cl, [rax]
    ; mov r8b, [rcx]
    mov r12b, [rbx]
    cmp r12b, cl
    jne %%_strncmp_false
    inc rbx
    inc rax
    inc r10
    cmp r10, r9
    jne %%_strncmp_loop
%%_strncmp_true:
    mov rax, 1
    jmp %%_strncmp_end
%%_strncmp_false:
    mov rax, 0
%%_strncmp_end:
%endmacro

; parse the mime type from request_uri and update the type to rax
%macro parse_mime_type 0
%%_parse_mime_type:
    mov rax, request_uri
    mov ebx, [request_urilen]
    add rax, rbx
    mov rbx, 0 ; rbx is the length of the read chars
%%_mime_read_loop:
    ; first compare if the whole uri is read
    ; if the whole uri is read without findinf a dot assume MIME_BLOB
    cmp rbx, [request_urilen]
    je %%_set_mime_blob
    inc rbx
    dec rax
    ;TODO: why doesnt this work
    ; mov cl, [rax]
    ; cmp cl, 46
    cmp byte[rax], 46 ; compare the current char to '.'
    jne %%_mime_read_loop
%%_mime_compares:
    mov r14, rax
    mov r15, rbx
    strncmp mime_html, r14, 5, r15
    cmp rax, 1
    je %%_set_mime_html
    strncmp mime_css, r14, 4, r15
    cmp rax, 1
    je %%_set_mime_css
    strncmp mime_js, r14, 3, r15
    cmp rax, 1
    je %%_set_mime_js


%%_set_mime_blob:
    mov rax, MIME_BLOB
    jmp %%_parse_mime_end_unload
%%_set_mime_html:
    mov rax, MIME_HTML
    jmp %%_parse_mime_end_unload
%%_set_mime_js:
    mov rax, MIME_JS
    jmp %%_parse_mime_end_unload
%%_set_mime_css:
    mov rax, MIME_CSS
%%_parse_mime_end_unload:
    ; just unload the stack
%%_parse_mime_end:
%endmacro


;;;
; Mime types
;;
MIME_BLOB equ 0
MIME_HTML equ 1
MIME_JS   equ 2
MIME_CSS  equ 3
