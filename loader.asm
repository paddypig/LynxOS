[BITS 16]
[ORG 0x7E00]

start:
    ; 显示加载内核信息
    mov si, loader_msg
    call print_string

    ; 切换到保护模式
    cli                     ; 禁用中断
    lgdt [gdt_descriptor]   ; 加载全局描述符表
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax            ; 设置保护模式标志位
    jmp CODE_SEG:protected_mode_entry

; 打印字符串函数
print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

; 全局描述符表 (GDT)
GDT_START:
    dd 0x0
    dd 0

CODE_SEG:
    dw 0xFFFF        ; 段界限低 16 位
    dw 0x0           ; 基地址低 16 位
    db 0x0           ; 基地址中 8 位
    db 0x9A          ; 访问权限
    db 0xCF          ; 粒度
    db 0x0           ; 基地址高 8 位

DATA_SEG:
    dw 0xFFFF        ; 段界限低 16 位
    dw 0x0           ; 基地址低 16 位
    db 0x0           ; 基地址中 8 位
    db 0x92          ; 访问权限
    db 0xCF          ; 粒度
    db 0x0           ; 基地址高 8 位

GDT_END:

gdt_descriptor:
    dw GDT_END - GDT_START - 1
    dd GDT_START

[BITS 32]
protected_mode_entry:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; 初始化中断描述符表 (IDT)
    extern idt_init
    call idt_init

    ; 开启分页机制
    extern paging_init
    call paging_init
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    ; 跳转到内核入口，初始化进程调度
    extern kmain
    call kmain

    jmp $            ; 无限循环

loader_msg db 'Switching to protected mode...', 0
idt_load:
    lidt [esp + 4]
    ret