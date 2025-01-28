[org 0x1000]          ; Kernel is loaded at memory address 0x1000
bits 16               ; Real mode

start:
    ; Print message: Kernel loaded
    mov si, kernel_msg
    call print_string

    ; Create a new partition
    call create_partition

    ; Install the operating system onto the new partition
    call install_os

    ; Remove all other partitions
    call delete_other_partitions

    ; Kernel task complete, halt
    mov si, success_msg
    call print_string
    hlt                 ; Halt the system

; Create a new partition
create_partition:
    ; Placeholder logic: Assume partition creation happens here
    mov si, partition_msg
    call print_string
    ret

; Install the operating system onto the partition
install_os:
    ; Placeholder logic: Simulate OS installation
    mov si, install_msg
    call print_string
    ret

; Delete all other partitions and operating systems
delete_other_partitions:
    ; Placeholder logic: Simulate deletion of other partitions
    mov si, delete_msg
    call print_string
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
kernel_msg db "Kernel loaded and running...", 0x0D, 0x0A, '$'
partition_msg db "Creating new partition...", 0x0D, 0x0A, '$'
install_msg db "Installing operating system...", 0x0D, 0x0A, '$'
delete_msg db "Deleting other partitions...", 0x0D, 0x0A, '$'
success_msg db "Kernel task complete. System ready!", 0x0D, 0x0A, '$'
