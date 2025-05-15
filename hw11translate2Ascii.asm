section .data
    inputBuf db  0x83, 0x6A, 0x88, 0xDE, 0x9A, 0xC3, 0x54, 0x9A
    inputLen equ $ - inputBuf
    hexChars db '0123456789ABCDEF'
    newline db 0x0A

section .bss
    outputBuf resb 80

section .text
    global _start

_start:
    mov esi, inputBuf        ; ESI points to inputBuf
    mov edi, outputBuf       ; EDI points to outputBuf
    mov ecx, inputLen        ; ECX = number of bytes to process

convert_loop:
    lodsb                    ; Load byte from [ESI] into AL and increment ESI
    mov ah, al               ; Store original byte in AH

    ; Extract high nibble (top 4 bits)
    shr al, 4                ; Shift right to isolate high nibble
    and al, 0x0F             ; Mask to get lower 4 bits of high nibble
    mov bl, [hexChars + eax] ; Get ASCII char from hexChars
    stosb                    ; Store ASCII char to outputBuf

    ; Extract low nibble (bottom 4 bits)
    mov al, ah               ; Restore original byte
    and al, 0x0F             ; Mask to get low nibble
    mov bl, [hexChars + eax] ; Get ASCII char from hexChars
    stosb                    ; Store ASCII char to outputBuf

    ; Add a space after each byte's hex
    mov al, ' '
    stosb

    loop convert_loop        ; Repeat for each byte

    ; Replace last space with newline
    dec edi
    mov byte [edi], 0x0A     ; newline character

    ; Print outputBuf
    mov eax, 4               ; syscall: sys_write
    mov ebx, 1               ; file descriptor: stdout
    mov ecx, outputBuf       ; buffer to write
    mov edx, edi             ; calculate length to write
    sub edx, outputBuf
    inc edx                  ; include newline
    int 0x80                 ; call kernel

    ; Exit program
    mov eax, 1               ; syscall: sys_exit
    xor ebx, ebx             ; exit code 0
    int 0x80
