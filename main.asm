;---------------------------------------
; 64 bit, threaded test on
; drcctlib_instr_analysis.
; uses the syscall SYS_clone.
; Uses Christopher Wellons
; (https://github.com/skeeto/pure-linux-threads-demo)
; code to create and set up threads.
;---------------------------------------
bits 64                                ; AMD64 Linux ONLY
;---------------------------------------
; Functions from real.asm
;---------------------------------------
extern loads                           ; Execute additional loads
extern stores                          ; Execute additional stores
extern ubr                             ; Execute additional unconditional branches
extern cbr                             ; Execute additional conditional branches
;---------------------------------------
; Global exports
;---------------------------------------
global _start                          ; main function
;---------------------------------------
; sys/syscall.h
;---------------------------------------
%define SYS_write	1              ; Write system call
%define SYS_mmap	9              ; Memory map system call
%define SYS_clone	56             ; Clone (create thread) system call
%define SYS_exit	60             ; Exit system call
;---------------------------------------
; unistd.h
;---------------------------------------
%define STDIN		0              ; STDIN file descriptor
%define STDOUT		1              ; STDOUT file descriptor
%define STDERR		2              ; STDERR file descriptor
;---------------------------------------
; sched.h
;---------------------------------------
%define CLONE_VM	0x00000100     ; Bitflag arg for clone syscall
%define CLONE_FS	0x00000200     ; Bitflag arg for clone syscall
%define CLONE_FILES	0x00000400     ; Bitflag arg for clone syscall
%define CLONE_SIGHAND	0x00000800     ; Bitflag arg for clone syscall
%define CLONE_PARENT	0x00008000     ; Bitflag arg for clone syscall
%define CLONE_THREAD	0x00010000     ; Bitflag arg for clone syscall
%define CLONE_IO	0x80000000     ; Bitflag arg for clone syscall
;---------------------------------------
; sys/mman.h
;---------------------------------------
%define MAP_GROWSDOWN	0x0100         ;
%define MAP_ANONYMOUS	0x0020         ;
%define MAP_PRIVATE	0x0002         ;
%define PROT_READ	0x1            ;
%define PROT_WRITE	0x2            ;
%define PROT_EXEC	0x4            ;
%define THREAD_FLAGS \
 CLONE_VM | \
 CLONE_FS | \
 CLONE_FILES | \
 CLONE_SIGHAND | \
 CLONE_PARENT | \
 CLONE_THREAD | \
 CLONE_IO                              ; Thread bitfield arguments
%define STACKSIZE	(4096 * 1024)  ; Stack size (roughly 2mb)
%define MAX_LINES	10             ; number of output lines before exiting
;---------------------------------------
section .data                          ; Begin data segment
;---------------------------------------
count:	dq MAX_LINES                   ; Count from max lines to 0
;---------------------------------------
section .text                          ; Begin code-containing segment
;---------------------------------------
_start:                                ; Main function
	mov rdi, loads                 ; Store address of loads function
	call thread_create             ; Create thread with loads function
	mov rdi, stores                ; Store address of stores function
	call thread_create             ; Create thread with stores function
	mov rdi, ubr                   ; Store address of unconditional branches funtion
	call thread_create             ; Create thread with unconditional branch function
	mov rdi, cbr                   ; Store address of conditional branch function
	call thread_create             ; Create thread with unconditional branch function
        mov       rax, 60              ; system call for exit
        xor       rdi, rdi             ; exit code 0
        syscall                        ; Invoke exit syscall
;---------------------------------------
;; long thread_create(void (*)(void))
;---------------------------------------
thread_create:                         ;
	push rdi                       ; Save RDI before function call
	call stack_create              ; Create a stack
	lea rsi, [rax + STACKSIZE - 8] ; Put RSI at where thread function is
	pop qword [rsi]                ; load function into RSI
	mov rdi, THREAD_FLAGS          ; Set RDI to thread flags for syscall
	mov rax, SYS_clone             ; Set RAX to thread creation syscall
	syscall                        ; Perform clone() syscall
	ret                            ; Return from thread_create
;---------------------------------------
;; void *stack_create(void)
;---------------------------------------
stack_create:                          ;
	mov rdi, 0                     ; Clear RDI
	mov rsi, STACKSIZE             ; Move STACKSIZE into rsi
	mov rdx, PROT_WRITE \
                 | PROT_READ           ; Set protections of stack to RW
	mov r10, MAP_ANONYMOUS \
                 | MAP_PRIVATE \
                 | MAP_GROWSDOWN       ; load R10 with stack attribs
	mov r8, -1                     ; Part of syscall not sure
	mov r9, 0                      ; Part of syscall not sure
	mov rax, SYS_mmap              ; Ready mmap() syscall
	syscall                        ; Perform mmap() syscall
	ret                            ; return from stack_create
;---------------------------------------
; real_main.asm ends here
;---------------------------------------
