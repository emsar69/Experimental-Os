void print_VGA(const char* str) {
    char* VGA = (char*)0xB8000;

    for(int i = 0; str[i]; i++){
        VGA[i*2]   = str[i];
        VGA[i*2+1] = 0x1F;
    }
}

__attribute__((section(".text.entry")))
void kernel_main() {
    print_VGA("HELLO FROM KERNEL!");
    while(1){
        __asm__ volatile("hlt");
    }
}