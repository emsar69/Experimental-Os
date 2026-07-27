void print_VGA(const char* str) {
    char* VGA = (char*)0xB8000;

    for(int i = 0; str[i]; i++){
        VGA[i*2]   = str[i];
        VGA[i*2+1] = 0x1F;
    }
}

void main() {
    print_VGA("HELLO FROM KERNEL!");
    while(1){

    }
}