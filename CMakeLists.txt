cmake_minimum_required(VERSION 4.1)
project(boot LANGUAGES ASM C)

set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(SRC_BOOT ${SRC_DIR}/boot)
set(SRC_BOOT_INCLUDE ${SRC_BOOT}/include)
find_program(dd NAMES dd REQUIRED)

add_custom_command(
    OUTPUT stage1.bin
    COMMAND nasm ${SRC_BOOT}/stage1.asm -o stage1.bin -f bin -I ${SRC_BOOT_INCLUDE}
    DEPENDS ${SRC_BOOT}/stage1.asm
)
add_custom_command(
    OUTPUT stage2.bin
    COMMAND nasm ${SRC_BOOT}/stage2.asm -o stage2.bin -f bin -I ${SRC_BOOT_INCLUDE}
    DEPENDS ${SRC_BOOT}/stage2.asm
)
add_custom_command(
    OUTPUT boot.img
    COMMAND dd if=/dev/zero of=boot.img bs=512 count=2048 # 2048 sect
    COMMAND dd if=stage1.bin of=boot.img conv=notrunc bs=512 count=1 status=progress
    COMMAND dd if=stage2.bin of=boot.img conv=notrunc bs=512 seek=1 count=31 status=progress # Count is for limit. 31 section is not needed.
    DEPENDS stage1.bin stage2.bin
)

# TODO:
# hibrit iso, en baştaki 0.mbr section sadece dd olduğunda hayatta kalacağı için iso okumalı.
# iso içindeki el torito ile belirtilen bootloader ise rufus ile program tarafından
# formatlanacağı için fat32 dosya sistemini okumalı. Toplamda 2 stage fakat türe göre farklı.
# fat32 partitionu sector 2048e koyarım. şuanda 1.de :skull:

add_custom_target(build_img ALL DEPENDS stage1.bin boot.img)