#
# Игра Змейка
# здесь реализован главный цикл управления программой
#

#include "graphics.S"
#include "debug.S"

.global main

.section .rodata
.equ ROWS    , 25                                                 # количество строк
.equ COLUMNS , 80                                                 # количество столбцов

.text
main:
    init_board ROWS, COLUMNS
    
    return_cursor ROWS

    j exit
exit:
    li a0, 0x0
    ret
      
