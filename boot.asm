[BITS 16]
[ORG 0x7C00]

start:
    ; 设置段寄存器
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; 显示引导信息
    mov si, boot_msg
    call print_string

    ; 加载引导加载器
    mov bx, 0x1000       ; 加载地址
    mov dh, 1            ; 读取扇区数
    mov dl, [BOOT_DRIVE] ; 引导驱动器号
    call disk_load

    ; 跳转到引导加载器
    jmp 0x1000

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

; 磁盘读取函数
disk_load:
    pusha
    mov ah, 0x02         ; BIOS 读扇区功能
    mov al, dh           ; 读取扇区数
    mov ch, 0x00         ; 柱面号
    mov cl, 0x02         ; 起始扇区号
    mov dh, 0x00         ; 磁头号
    int 0x13
    jc disk_error        ; 检查错误
    popa
    ret

; 磁盘错误处理
    disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $ 

; 数据定义
BOOT_DRIVE db 0
boot_msg db 'Booting...', 0
    disk_error_msg db 'Disk read error!', 0

; 填充剩余空间并添加引导标志
times 510-($-$$) db 0
dw 0xAA55