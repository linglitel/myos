ENTRY(_start)

PHDRS
{
    text PT_LOAD FLAGS(rx);    /* 可执行的代码段 */
    rodata PT_LOAD FLAGS(r);   /* 只读数据段 */
    data PT_LOAD FLAGS(rw);    /* 可读写的数据段 */
}

SECTIONS {
    . = 1M;

    /* 将 .text 段分配到 text 程序头 */
    .text BLOCK(4K) : ALIGN(4K) {
        *(.multiboot)
        *(.text)
    } : text

    /* 将 .rodata 段分配到 rodata 程序头 */
    .rodata BLOCK(4K) : ALIGN(4K) {
        *(.rodata)
    } : rodata

    /* 将 .data 段分配到 data 程序头 */
    .data BLOCK(4K) : ALIGN(4K) {
        *(.data)
    } : data

    /* 将 .bss 段分配到 data 程序头 */
    .bss BLOCK(4K) : ALIGN(4K) {
        *(COMMON)
        *(.bss)
    } : data
}
