[org 0x7C00]
bits 16

start:
    mov si, boot_msg1
    call print_string

    xor ax, ax          ; Set DS and ES to 0
    mov ds, ax
    mov es, ax

    ; Print boot message
    mov si, boot_msg
    call print_string

    ; Attempt to read the kernel
    mov ah, 0x02        ; BIOS function to read sectors
    mov al, 1           ; Read one sector
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start reading at sector 2
    mov dh, 0           ; Head 0
    mov dl, 0           ; Drive 0 (floppy or HDD)
    mov bx, 0x1000      ; Load kernel at memory 0x1000
    int 0x13            ; BIOS disk interrupt
    jc disk_error       ; Jump to error handler if carry flag is set

    ; Print success message if the kernel is loaded
    mov si, loaded_msg
    call print_string

    ; Jump to the kernel
    jmp 0x1000

disk_error:
    mov si, error_msg
    call print_string
    hlt                 ; Halt the system

print_string:
    mov ah, 0x0E        ; BIOS teletype output
.next_char:
    lodsb
    cmp al, '$'
    je .done
    int 0x10
    jmp .next_char
.done:
    ret

boot_msg1 db "Bootloader loaded succesfully...", 0x0D, 0x0A, '$'
boot_msg db "Booting the kernel...", 0x0D, 0x0A, '$'
loaded_msg db "Kernel loaded successfully...", 0x0D, 0x0A, '$'
error_msg db "Disk read error!", 0x0D, 0x0A, '$'

times 510-($-$$) db 0
dw 0xAA55