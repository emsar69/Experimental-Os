bits 16
org 0x7C00

; STAGE 1
; SECTOR: 0
; LOAD ADDR: 0x7C00

jmp 0x0000:start ; to set cs 0

%include "commonstage.inc"

start:
    cli
    xor ax, ax
    mov ss, ax
    mov es, ax
    mov ds, ax
    mov sp, 0x7C00
    mov bp, sp
    sti

    mov si, text ; By my definition, for printing: Set si to addr of text.
    call print

    mov ah, 2
    mov al, 31 ; 1-31
    mov ch, 0
    mov cl, 2
    mov dh, 0
    ; dl is same because it's literally not changed for whole code.
    mov bx, 0x8000 ; Addr to load :)
    int 0x13

    jc disk_read_error

    jmp 0x8000 ; Jump to stage 2

disk_read_error:
    mov si, disk_fail
    call print
    cli
    hlt

text db "Hello from stage1!!", 13, 10, 0 ; 13d 10d = 0xD 0xA = "\r\n"
disk_fail db "Failed to load from disk.", 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55