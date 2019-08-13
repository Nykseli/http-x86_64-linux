;;;
; Includes for linux x86_64
; Contains the needed system call ids, stdio ids etc
;;


;;;
; stdio
;;
STDIN   equ 0
STDOUT  equ 1
STDERR  equ 2

;;;
; SYS_OPEN options
;;
O_RDONLY    equ    0
O_WRONLY    equ    1
O_RDWR      equ    2
O_CREAT     equ   64
O_EXCL      equ  128
O_APPEND    equ 1024
O_NONBLOCK  equ 2048

;;;
; Shutdown options (how flag)
;;
SHUT_RD   equ 0
SHUT_WR   equ 1
SHUT_RDWR equ 2

;;;
; Protocol families
;;
PF_INET  equ  2 ; ipv4
PF_INET6 equ 10 ; ipv6

;;;
; Address families
;;
AF_INET  equ PF_INET  ; ipv4
AF_INET6 equ PF_INET6 ; ipv6

;;;
; Socket options
;;
SOL_SOCKET   equ 1
SO_REUSEADDR equ 2
; backlog argument defines the maximum length to which the queue of
; pending connections for sockfd may grow
SOCK_BACKLOG equ 10

;;;
; Socket type
;;
SOCK_STREAM equ 1 ; Sequenced, reliable, connection-based byte streams.

;;;
; Standard well-defined IP protocols
;;
IPPROTO_TCP equ  6 ; tcp
IPPROTO_UDP equ 17 ; udp

;;;
; System calls
;;
SYS_READ       equ   0
SYS_WRITE      equ   1
SYS_OPEN       equ   2
SYS_CLOSE      equ   3
SYS_NANOSLEEP  equ  35
SYS_SOCKET     equ  41
SYS_ACCEPT     equ  43
SYS_SENDTO     equ  44
SYS_RECVFROM   equ  45
SYS_SENDMSG    equ  46
SYS_RECVMSG    equ  47
SYS_SHUTDOWN   equ  48
SYS_BIND       equ  49
SYS_LISTEN     equ  50
SYS_SETSOCKOPT equ  54
SYS_EXIT       equ  60
