;---------------------------------------
; Functions that do memory loads,
; memory stores, unconditional branches,
; and conditional branches.
;---------------------------------------

;---------------------------------------
; Globals
;---------------------------------------
global loads                           ; Function that executes additional loads
global stores                          ; Function that executes additional stores
global ubr                             ; Function that executes additional unconditional branches
global cbr                             ; Function that executes additional conditional branches
;---------------------------------------
section .data                          ; Begin data segment
;---------------------------------------
toloadfrom dw 0                        ; Load from this address
tostoreto dw 0                         ; Store to this address
;---------------------------------------
section   .text                        ; Begin code-containing segment
;---------------------------------------
; Load a word's worth of data.
; Do nothing else with that data.
;---------------------------------------
loads:                                 ;
        lea rsi, [rel toloadfrom]      ; rsi = &toloadfrom;
        mov rax, [rsi]                 ; rax = *rsi;
        mov       rax, 60              ; system call for exit
        xor       rdi, rdi             ; exit code 0
        syscall                        ; Invoke exit syscall
;---------------------------------------
; Store 1 in "tostoreto".
; Do nothing else with that data.
;---------------------------------------
stores:                                ;
        mov rax, 1                     ; rax = 1;
        lea rdi, [rel tostoreto]       ; rsi = &toloadfrom;
        mov [rdi], rax                 ; *rsi = rax;
        mov       rax, 60              ; system call for exit
        xor       rdi, rdi             ; exit code 0
        syscall                        ; Invoke exit syscall
;---------------------------------------
; Perform an unconditional branch.
;---------------------------------------
ubr:                                   ;
        jmp uselesslabel               ; Jump to a useless label
;---------------------------------------
; A useless label.
;---------------------------------------
uselesslabel:                          ;
        mov       rax, 60              ; system call for exit
        xor       rdi, rdi             ; exit code 0
        syscall                        ; Invoke exit syscall
;---------------------------------------
; Perform a conditional branch
;---------------------------------------
cbr:                                   ;
        mov rax, 1                     ; rax = 1;
        mov rbx, 1                     ; rbx = 1;
        cmp rax, rbx                   ; Compare rax and rbx
        je otheruselesslabel           ; Jump to another useless label
;---------------------------------------
; Another useless label
;---------------------------------------
otheruselesslabel:                     ;
        mov       rax, 60              ; system call for exit
        xor       rdi, rdi             ; exit code 0
        syscall                        ; Invoke exit syscall
;---------------------------------------
; real.asm ends here.
;---------------------------------------
