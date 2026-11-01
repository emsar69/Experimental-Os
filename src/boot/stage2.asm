LOAD_ADDR equ 0x8000

bits 16
org 0x8000

; STAGE 2
; SECTOR: 1-31
; LOAD ADDR: 0x8000
; TOTAL POSSIBLE BYTES: 15872

jmp start

%include "commonstage.inc"

gdt_start:
    dd 0,0

    ; CODE SEGMENT (0x8) DPL = 0
    dw 0xFFFF       ; Limit (16 bits)
    db 0, 0, 0      ; base (24 bits)
    db 0b10011010   ; Access Byte (8 bits)
    db 0b11001111   ; Flags + high limit (4 + 4 bits)
    db 0            ; high base (8 bits)

    ; DATA SEGMENT (0x10) DPL = 0
    dw 0xFFFF       ; Limit (16 bits)
    db 0, 0, 0      ; base (24 bits)
    db 0b10010010   ; Access Byte (8 bits)
    db 0b11001111   ; Flags + high limit (4 + 4 bits)
    db 0            ; high base (8 bits)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

idt_start:
    dw (int_test - $$ + LOAD_ADDR) & 0xFFFF ; offset (16 bits)
    dw 0x8                                  ; segment selector (16 bits) & selected CS
    db 0                                    ; reserved (8 bits)
    db 0b10001110                           ; P & DPL & PAD(0) & GATE (8 bits)
    dw (int_test - $$ + LOAD_ADDR) >> 16    ; offset high (16 bits)

idt_end:

idt_descriptor:
    dw idt_end - idt_start - 1
    dd idt_start

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

    ; try enabling a20
    mov ah, 0x24
    mov al, 0x1
    int 0x15

    in al, 0x92
    or al, 0x2
    out 0x92, al

    ; ENABLE PROTECTED MODE
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    lgdt [gdt_descriptor]
    lidt [idt_descriptor]
    sti

    jmp 0x8:protected_mode


    ; TODO: Compile the kernel as elf, read headers
    ; load segments(cs,ds,...) to ram (addr: 0x100000) and jump to it
    ; real/protected mode
    cli
    hlt

bits 32
int_test: ; just testing
    mov eax, 0xB8030
    mov [eax], 'L'
    inc eax
    mov [eax], 0x1f
    iret

bits 32
protected_mode:
    mov ax, 0x10 ; DS selector
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x90000

    ; todo: Load kernel
    int 0x0

    cli
    hlt

nbr db "Hello from stage 2!!", 13, 10, 0