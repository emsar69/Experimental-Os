print_loop:
    lodsb
    cmp al, 0
    jz print_loop_ret
    int 0x10
    jmp print_loop
print_loop_ret:
    ret

print:
    push bp
    mov bp, sp

    mov ah, 0xE
    mov bh, 0x0
    mov bl, 0x7
    call print_loop

    mov sp, bp
    pop bp
    ret