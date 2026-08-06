#
# макросы отвечающие за:
# отрисовку доски
# отрисовку змейки
# отрисоку яблок
#

#ifndef GRAPHICS_S_
#define GRAPHICS_S_

#include "debug.S"

.section .rodata
clear_screen_ascii: .asciz "\x1B[2J"
move_cursor_ascii:  .asciz "\x1b[%d;%dH"


#
# очистка экрана
# используемые регистры: a0
#
.MACRO clear_screen
    save_all_regs                                           # сохраняет все регистры в стеке
    la a0, clear_screen_ascii                               # загружает в a0 адрес форматной строки
    call printf                                             # вызывает библиотечную функцию printf
    load_all_regs                                           # загружает из стека сохраненные значения
.ENDM

#
# передвижение курсора
# reg_x - координата x (регистр)
# reg_y - координата y (регистр)
# используемые регистры: a0, a1, a2
#
.MACRO move_cursor reg_x, reg_y
    save_all_regs                                           # сохраняет все регистры в стеке  
    la a0, move_cursor_ascii                                # загружает в a0 адрес форматной строки
    mv a1, \reg_y                                           # копируем y из reg_y в a1
    mv a2, \reg_x                                           # копируем x из reg_x в a2
    call printf                                             # вызываем библиотечную функцию printf
    load_all_regs                                           # загружает из стека сохраненные значения
.ENDM

#
# печатает ascii символ в текущей позиции курсора
# ascii_code - номер символа в таблице (константа)
# используемые регистры: a0
#
.MACRO print_symbol ascii_code
    save_all_regs                                           # сохраняет все регистры в стеке
    li a0, \ascii_code                                      # a0 теперь хранит ascii_code
    call putchar                                            # вызываем библиотечную функцию putchar
    load_all_regs                                           # загружает из стека сохраненные значения
.ENDM    

#
# рисуем игровое поле
# rows - количество строк в поле (константа)
# columns - количество столбцов в поле (константа)
# используемые регистры: t0, t1, t2, t3, t4, t5, t6
#
.MACRO print_board rows, columns
    save_all_regs                                           # сохраняем все регистры в стек
    li t0, \rows                                            # t0 теперь хранит rows
    li t1, \columns                                         # t1 теперь хранит columns
    li t2, 0x1                                              # t2 содержит координату по x
    li t3, 0x1                                              # t3 содерижт координату по y
    
    rows_loop:
    bltu t0, t3, end_rows_loop                              # если y > rows - завершаем цикл по строкам
    columns_loop:
    bltu t1, t2, end_columns_loop                           # если x > columns - завершаем цикл по столбцам
    move_cursor t2, t3                                      # перемещаем курсор в позицию (x,y)
    y_condition:
    li t5, 0x1                                              # загружаем 1 для стравнения
    xor t5, t3, t5                                          # если y == 1, то t5 = 0
    seqz t5, t5                                             # если t5 == 0, то t5 = 1
    xor t6, t3, t0                                          # если y == rows, to t6 = 0
    seqz t6, t6                                             # если t6 == 0, то t6 = 1
    or t4, t5, t6                                           # t4 = t5 || t6
    li t5, 0x1                                              # загружаем 1 для сравнения
    bne t4, t5, x_condition                                 # если !(t4 == 1) переходим к условию на x
    print_symbol '-'                                        # печатаем -
    j continue_x_loop                                       # переходим в начало цикла по строкам
    x_condition:
    li t5, 0x1                                              # загружаем 1 для сравнения
    xor t5, t2, t5                                          # если x == 1, то t5 = 0
    seqz t5, t5                                             # если t5 == 0, t5 = 1
    xor t6, t2, t1                                          # если x == columns, t6 = 0
    seqz t6, t6                                             # если t6 == 0, t6 = 1
    or t4, t5, t6                                           # t4 = t5 || t6
    li t5, 0x1                                              # загружаем 1 для сравнения
    bne t4, t5, default_action                              # если t4 != t5, печатаем дефолтный символ
    print_symbol '|'                                        # печатаем |
    j continue_x_loop
    default_action:
    print_symbol ' '                                        # печатаем пробел
    continue_x_loop:
    addi t2, t2, 0x1                                        # x += 1
    j columns_loop
    end_columns_loop:
    addi t3, t3, 0x1                                        # y += 1
    li t2, 0x1                                              # x = 1
    j rows_loop
    end_rows_loop:
    
    load_all_regs                                           # загружаем значения из стека в регистры
.ENDM

#
# отрисовки поля
# rows - количество строк в поле (константа)
# columns - количество столбцов в поле (константа)
# используемые регистры: 
#
.MACRO init_board rows, columns
    clear_screen                                            # очищаем экран
    print_board \rows, \columns                             # рисуем игровое поле
.ENDM

#
# перемещает курсор под игровое поле
# rows - количество строк (регистр)
# используемые регистры: t0, t1
#
.MACRO return_cursor rows
    save_all_regs                                           # сохраняем все регистры в стек
    li t0, 0x1                                              # загружаем координату x
    li t1, \rows                                            # загружаем количество строк
    addi t1, t1, 0x1                                        # y = ROWS + 1
    move_cursor t0, t1
    load_all_regs                                           # загруажаем все регистры из стека
.ENDM

.text                                                       # переключаемся в секцию text
#endif
