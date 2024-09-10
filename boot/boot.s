; boot/boot.s
bits 32
section .multiboot
align 4
    dd 0x1BADB002              ; Multiboot magic number
    dd 0x0                     ; Flags
    dd - (0x1BADB002 + 0x0)    ; Checksum

section .bss
align 16
stack_bottom:
    resb 16384 ; 16 KiB
stack_top:

section .text
global _start
_start:
    ; Set up the stack
    mov esp, stack_top

    ; Set up paging
    ; Identity map first 2MB
    mov eax, p3_table
    or eax, 0b11 ; present + writable
    mov [p4_table], eax
    
    mov eax, p2_table
    or eax, 0b11 ; present + writable
    mov [p3_table], eax
    
    mov ecx, 0
.map_p2_table:
    mov eax, 0x200000 ; 2MB page
    mul ecx
    or eax, 0b10000011 ; present + writable + huge
    mov [p2_table + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Set the long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, p4_table
    mov cr3, eax

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Load the GDT
    lgdt [gdt64.pointer]

    ; Update selectors
    mov ax, gdt64.data
    mov ss, ax
    mov ds, ax
    mov es, ax

    ; Jump to long mode
    jmp gdt64.code:long_mode_start

section .bss
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

section .rodata
gdt64:
    dq 0 ; zero entry
.code: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment
.data: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41) ; data segment
.user_code: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) | (3 << 45) ; User code segment
.user_data: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41) | (3 << 45) ; User data segment
.tss: equ $ - gdt64
    dq 0 ; TSS (to be filled later)
    dq 0
.pointer:
    dw $ - gdt64 - 1
    dq gdt64
section .bss
align 16
tss:
    resb 104

section .text
bits 64
long_mode_start:
    ; Clear the screen
    mov rax, 0x1f201f201f201f20
    mov rcx, 500
    mov rdi, 0xb8000
    rep stosq

    ; Call the kernel main function
    extern kernel_main
    call kernel_main

    ; If we return from the kernel, just halt
    hlt