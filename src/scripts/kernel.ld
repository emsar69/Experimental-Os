ENTRY(kernel_main) // not needed btw, only for elf binaries

SECTIONS {
    . = 0x100000
    .text = {
        *(.text.entry)
        *(.text*)
    }

    .rodata = {*(.rodata*)}
    .data = {*(.data*)}
}