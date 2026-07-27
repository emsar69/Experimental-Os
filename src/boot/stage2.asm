bits 16
org 0x8000

; STAGE 2
; SECTOR: 1-31
; LOAD ADDR: 0x8000
; TOTAL POSSIBLE BYTES: 15872

jmp start

%include "commonstage.inc"

itoa: ; ax = num (not preserved)
    xor dx, dx
    mov bx, 0xA ; /10
    div bx ; remainder = dx
    add dl, '0'

    push ax
    mov al, dl
    stosb
    pop ax

    test ax, ax
    jnz itoa

    ;ax is already 0
    stosb ; writes null terminator
    ret ; result is reversed btw. I'm too lazy for fix.

start:
    mov si, nbr
    call print

    int 0x12 ; ax = memsize
    sub sp, 128 ; I'm gonna write it directly to stack.
    mov di, sp
    cld
    call itoa

    mov si, sp ; start of str
    call print

    add sp, 128


    ; TODO: Compile the kernel as elf, read headers
    ; load segments(cs,ds,...) to ram (addr: 0x100000) and jump to it
    ; real/protected mode
    cli
    hlt

nbr db "Hello from stage 2!!", 13, 10, 0