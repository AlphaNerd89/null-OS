[org 0x7E00]          ; OS is loaded at memory address 0x7E00
bits 16               ; Real mode

start:
    ; Print message: OS starting
    mov si, os_msg
    call print_string

    ; Switch to graphical mode (320x200, 256 colors)
    mov ax, 0x0013    ; Video mode 13h
    int 0x10          ; BIOS video interrupt

    ; Display the image
    call display_image

    ; Wait for a keypress to exit
    mov ah, 0x00
    int 0x16          ; BIOS keyboard interrupt

    ; Return to text mode (80x25)
    mov ax, 0x0003    ; Video mode 03h
    int 0x10          ; BIOS video interrupt

    ; Print message: OS finished
    mov si, finished_msg
    call print_string

    hlt               ; Halt the system

; Display the image
display_image:
    mov ax, 0xA000    ; Video memory starts at segment 0xA000
    mov es, ax        ; Set ES to video memory
    xor di, di        ; Start at offset 0x0000

    ; Load image data
    mov si, image_data
    mov cx, image_size

.next_pixel:
    lodsb             ; Load a byte from [SI] into AL
    stosb             ; Store AL into ES:[DI], increment DI
    loop .next_pixel  ; Repeat for all pixels

    ret

; Print string function
print_string:
    ; Print the string pointed to by SI
    ; Ends with '$'
    mov ah, 0x0E        ; BIOS teletype output
.next_char:
    lodsb               ; Load byte at [SI] into AL, increment SI
    cmp al, '$'         ; Check if end of string
    je .done
    int 0x10            ; Print character in AL
    jmp .next_char
.done:
    ret

; Data
os_msg db "Operating system starting...", 0x0D, 0x0A, '$'
finished_msg db "Operating system finished.", 0x0D, 0x0A, '$'

; Example image data (a simple gradient pattern)
image_data times 320*200 db 0x0F   ; A simple 320x200 white screen
image_size equ $ - image_data      ; Calculate the size of the image
