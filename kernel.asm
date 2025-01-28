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

    ; Delete all other partitions
    call delete_other_partitions

    ; Kernel task complete, halt
    mov si, success_msg
    call print_string
    hlt                 ; Halt the system

; Create a new partition
create_partition:
    ; Load MBR (sector 0 of the disk)
    mov ah, 0x02        ; BIOS read sectors
    mov al, 1           ; Read 1 sector
    xor ch, ch          ; Cylinder 0
    xor cl, cl          ; Start at sector 1
    xor dh, dh          ; Head 0
    mov dl, 0x80        ; First hard drive
    mov bx, mbr         ; Buffer to store MBR
    int 0x13            ; BIOS disk interrupt
    jc disk_error       ; Jump to error handler if read fails

    ; Modify the partition table (MBR + 446 is the start of the partition table)
    mov bx, mbr         ; Load MBR into BX
    add bx, 446         ; Offset to the partition table
    mov byte [bx], 0x80 ; Bootable flag
    mov word [bx+1], 0x0001 ; Starting CHS (Cylinder, Head, Sector)
    mov byte [bx+4], 0x83 ; Partition type (Linux)
    mov word [bx+5], 0xFEFF ; Ending CHS
    mov dword [bx+8], 0x00000001 ; Starting LBA
    mov dword [bx+12], 0x00020000 ; Total sectors (example size)

    ; Write the modified MBR back to disk
    mov ah, 0x03        ; BIOS write sectors
    mov al, 1           ; Write 1 sector
    xor ch, ch          ; Cylinder 0
    xor cl, cl          ; Start at sector 1
    xor dh, dh          ; Head 0
    mov dl, 0x80        ; First hard drive
    mov bx, mbr         ; Buffer containing modified MBR
    int 0x13            ; BIOS disk interrupt
    jc disk_error       ; Jump to error handler if write fails

    mov si, partition_msg
    call print_string
    ret

; Install the operating system onto the partition
install_os:
    ; Placeholder logic: Write a simple OS to the new partition (sector 2 onward)
    mov ah, 0x03        ; BIOS write sectors
    mov al, 10          ; Write 10 sectors (example size)
    xor ch, ch          ; Cylinder 0
    mov cl, 2           ; Start at sector 2
    xor dh, dh          ; Head 0
    mov dl, 0x80        ; First hard drive
    mov bx, os          ; Buffer containing the OS
    int 0x13            ; BIOS disk interrupt
    jc disk_error       ; Jump to error handler if write fails

    mov si, install_msg
    call print_string
    ret

; Delete all other partitions
delete_other_partitions:
    ; Wipe partition entries in the MBR (except the first one)
    mov bx, mbr         ; Load MBR into BX
    add bx, 462         ; Offset to the second partition entry
    mov cx, 3           ; Number of entries to wipe
.clear_entry:
    mov dword [bx], 0x00000000 ; Clear 4 bytes
    add bx, 16           ; Move to next entry
    loop .clear_entry

    ; Write modified MBR back to disk
    mov ah, 0x03        ; BIOS write sectors
    mov al, 1           ; Write 1 sector
    xor ch, ch          ; Cylinder 0
    xor cl, cl          ; Start at sector 1
    xor dh, dh          ; Head 0
    mov dl, 0x80        ; First hard drive
    mov bx, mbr         ; Buffer containing modified MBR
    int 0x13            ; BIOS disk interrupt
    jc disk_error       ; Jump to error handler if write fails

    mov si, delete_msg
    call print_string
    ret

; Disk error handler
disk_error:
    mov si, error_msg
    call print_string
    hlt                 ; Halt the system

; Print string function
print_string:
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
partition_msg db "Partition created successfully...", 0x0D, 0x0A, '$'
install_msg db "Operating system installed successfully...", 0x0D, 0x0A, '$'
delete_msg db "Other partitions deleted successfully...", 0x0D, 0x0A, '$'
success_msg db "Kernel task complete. System ready!", 0x0D, 0x0A, '$'
error_msg db "Disk operation failed!", 0x0D, 0x0A, '$'

mbr times 512 db 0x00   ; Buffer for the MBR
os times 5120 db 0x90   ; Example OS (10 sectors of NOP instructions)