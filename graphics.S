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
first_rule:                 .asciz "Enter 'a' to move to the left"
second_rule:                .asciz "Enter 'w' to move straight"
third_rule:                 .asciz "Enter 'd' to move to the right"
fourth_rule:                .asciz "Enter a space bar to complete the game"
score_msg:                  .asciz "You have %d points from %d points"
invite_msg:                 .asciz "Enter your move: "
clear_screen_ascii:         .asciz "\x1B[2J"
move_cursor_ascii:          .asciz "\x1b[%d;%dH"
clear_line_ascii:           .asciz "\x1b[2K"
clear_part_screen_ascii:    .asciz "\x1b[J"
clear_prev_line_ascii:      .asciz "\x1b[1A\x1b[2K"
win_msg:                    .asciz "\t\t\t\tYOU ARE WON"
lose_msg:                   .asciz "\t\t\t\tGAME OVER"
end_msg:                    .asciz "\t\t\tYOU HAVE COMPLETED THE GAME"

.section .data
end_line: .fill 80, 1, '='                                  # 80 элементов размером 1 байт со значением '='
          .byte 0x0                                         # окончание си строки 

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
# очистка строки
# используемые регистры: a0
#
.MACRO clear_line
    save_all_regs                                           # сохраняем все регистры в стеке
    la a0, clear_line_ascii                                 # загружаем в a0 адрес форматной строки
    call printf                                             # вызываем библиотечную функцию printf
    load_all_regs                                           # загружаем из стека сохраненные значения
.ENDM

#
# очистка строки выше
# используемые регистры: a0
#
.MACRO clear_prev_line 
    save_all_regs                                           # сохраняем все регистры в стек
    la a0, clear_prev_line_ascii                            # загружаем в a0 форматнуюю строку
    call printf                                             # вызываем библиотечную функцию
    load_all_regs                                           # загружаем все регистры из стека
.ENDM
#
# очистить часть экрана
# используемые регистры: a0
#
.MACRO clear_part_screen
    save_all_regs                                           # сохраняем все регистры в стек
    la a0, clear_part_screen_ascii                          # загружаем в a0 форматную строку
    call printf                                             # вызываем библиотечную функцию
    load_all_regs                                           # загружаем все регистры из стека
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
# используемые регистры: t0 - t6
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
# рисуем змею
# head_x - массив с координатами x (адрес)
# head_y - массив с координатами y (адрес)
# step - размер элемента массива в байтах (константа)
# snake_len - длина змеи (константа)
# используемые регистры: t0 - t6
# 
.MACRO print_snake head_x, head_y, step, snake_len
    save_all_regs                                          # сохраняем все регистры в стек
    li t0, 0x0                                             # t0 = 0x0
    li t6, 0x0                                             # t6 = 0x0
    la t1, \head_x                                         # загружаем в t1 адрес head_x
    la t2, \head_y                                         # загружаем в t2 адрес head_y
    li t3, \snake_len                                      # t4 = snake_len
    start_print:
    bgeu t0, t3, end_print                                 # если индекс >= длина - заканчивам печать
    lw t4, 0(t1)                                           # загружаем в t4 первый элемент по адресу в t1
    lw t5, 0(t2)                                           # загружаем в t5 второй элемент по адресу в t2
    move_cursor t4, t5                                     # перемещаем курсор в позицию с координатами (t4, t5) 
    bne t0, t6, default_print                              # если индекс не 0, печатаем 'o'
    print_symbol '@'                                       # печатаем голову
    j continue                                          
    default_print:
    print_symbol 'o'                                       # печатаем символ 'o'
    continue:
    addi t1, t1, \step                                     # увеличаем адрес на размер одного элемента
    addi t2, t2, \step                                     # увелиичваем адрес на размер одного элемента
    addi t0, t0, 0x1                                       # увеличиваем индекс
    j start_print
    end_print:
    load_all_regs                                          # загружаем все регистры из стека
.ENDM

#
# стирает змею с игрового поля
# head_x - массив с координатами x (адрес)
# head_y - массив с координатами y (адрес)
# step - размер одного элемента в байтах (константа)
# snake_len - длина змейки (константа)
# используемые регистры: t0 - t5
#
.MACRO clear_snake head_x, head_y, step, snake_len
    save_all_regs                                          # сохранить все регистры в стек
    li t0, 0x0                                             # счетчик
    la t1, \head_x                                         # загружаем адрес массива с координатами x
    la t2, \head_y                                         # загружаем адрес массива с координатами y
    li t3, \snake_len                                      # загружаем длину змеи
    start_clear_loop:
    bgeu t0, t3, end_clear_loop                            # если счетчик >= длина змеи - завершаем цикл
    lw t4, 0(t1)                                           # загружаем первый элемент массива в t4
    lw t5, 0(t2)                                           # загружаем первый элемент массива в t5
    move_cursor t4, t5                                     # перемещаем курсор
    print_symbol ' '                                       # затираем пробелом
    addi t0, t0, 0x1                                       # увеличиваем индекс
    addi t1, t1, \step                                     # смещаем указатель первого массива
    addi t2, t2, \step                                     # смещаем указатель второго массива
    j start_clear_loop
    end_clear_loop:
    load_all_regs                                          # загружаем все регистры из стека
.ENDM


#
# печать информационного сообщения
# info_x - координата x (константа)
# info_y - координата y (константа)
# используемые регистры: t0, t1
#
.MACRO print_info info_x, info_y
    save_all_regs                                          # сохраняем все регистры в стек
    li t0, \info_x                                         # t0 = info_x
    li t1, \info_y                                         # t1 = info_y
    move_cursor t0, t1                                     # перемещаем курсор под доску
    print_str first_rule                                   # выводим первое информационное сообщение
    addi t1, t1, 0x1                                       # t1 += 1
    move_cursor t0, t1                                     # перемещаем курсор на строку ниже
    print_str second_rule                                  # выводим второе информационное сообщение
    addi t1, t1, 0x1                                       # t1 += 1
    move_cursor t0, t1                                     # перемещаем курсор на строку ниже
    print_str third_rule                                   # выводим третье информационное сообщение
    addi t1, t1, 0x1                                       # t1 += 1
    move_cursor t0, t1                                     # перемещаем курсор на строку ниже
    print_str fourth_rule                                  # выводим четвертое информационное сообщенние
    load_all_regs                                          # загружаем все регистры из стека
.ENDM

#
# отрисовки поля
# rows - количество строк в поле (константа)
# columns - количество столбцов в поле (константа)
# info_x - координата x для информационного сообщения (константа)
# info_y - координата y для информационного сообщения (константа)
# используемые регистры: 
#
.MACRO init_board rows, columns, info_x, info_y
    clear_screen                                            # очищаем экран
    print_board \rows, \columns                             # рисуем игровое поле
    print_info \info_x, \info_y                             # выводим информационное сообщение
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

#
# приглашение пользователя к ходу
# invite_x - координата x выводимого сообщения
# invite_y - координата y выводимого сообщения
# используемые регистры: t0, t1, a0 
#
.MACRO print_invite invite_x, invite_y
    save_all_regs                                           # сохраняем все регистры в стек
    li t0, \invite_x                                        # t0 = invite_x
    li t1, \invite_y                                        # t1 = invite_y
    move_cursor t0, t1
    clear_line                                              # очистка строки
    move_cursor t0, t1
    la a0, invite_msg                                       # загружаем в a0 адрес сообщения с приглашением сходить
    call printf                                             # вызов библиотечной функции
    print_symbol '\n'
    load_all_regs                                           # загрузка регистров из стека
.ENDM

#
# печатаем яблоко
# apple_x - координата x яблока (адрес)
# apple_y - координата y яблока (адрес)
# используемые регистры: t0, t1, s1, s2
#
.MACRO print_apple apple_x, apple_y
    save_all_regs                                           # сохраняем все регистры в стек
    la t0, \apple_x                                         # загружаем адрес координаты x яблока
    la t1, \apple_y                                         # загружаем адрес координаты y яблока
    lw s1, 0(t0)                                            # загружаем координату x яблока
    lw s2, 0(t1)                                            # загружаем координату y яблока
    move_cursor s1, s2
    print_symbol '#'                                        # печатаем в текущей позиции курсора *
    load_all_regs                                           # загружаем все регистры из стека
.ENDM               

#
# стираем яблоко
# apple_x - координата x яблока (адрес)
# apple_y - координата y яблока (адрес)
# используемые регистры: t0, t1
#
.MACRO clear_apple apple_x, apple_y
    save_all_regs                                           # сохраняем все регистры в стек
    la t0, \apple_x                                         # загружаем адрес apple_x в t0
    lw t0, 0(t0)                                            # t0 = координата x яблока
    la t1, \apple_y                                         # загружаем адрес apple_y в t1
    lw t1, 0(t1)                                            # t1 = координата y яблока
    move_cursor t0, t1
    print_symbol ' '                                        # печатаем пробел в текущей позиции курсора
    load_all_regs                                           # загружаем все регистры из стека
.ENDM

#
# вывод очков игрока
# score_x - координата x (константа)
# score_y - координата y (константа)
# scores - количество очков (адрес)
# max_scores - максимально число очков (константа)
# используемые регистры: t0, t1, a0, a1, a2
#
.MACRO print_scores score_x, score_y, scores, max_scores
    save_all_regs                                           # сохраняем все регистры в стек
    li t0, \score_x                                         # t0 = score_x
    li t1, \score_y                                         # t1 = score_y
    move_cursor t0, t1
    clear_line                                              # очищаем текущую строку
    move_cursor t0, t1
    la t0, \scores                                          # загружаем в t0 адрес scores
    lw t0, 0(t0)                                            # загружаем в t0 количество очков 
    la a0, score_msg                                        # загружаем адрес форматной строки
    mv a1, t0                                               # копируем t0 в a1
    li a2, \max_scores
    call printf                                             # вызываем библиотечную функцию
    load_all_regs                                           # загружаем все регистры из стека
.ENDM

#
# печать полоски на ширину всего поля
# используемые регистры: a0
#
.MACRO print_end_line
    save_all_regs                                          # сохраняем все регистры в стек
    la a0, end_line                                        # загружаем форматную строку
    call printf                                            # вызываем библиотечную функцию
    load_all_regs                                          # сохраняем все регистры из стека
.ENDM


#
# печать сообщения о завершении игры 
# info_x - координата x сообщения (константа)
# info_y - координата y сообщения (константа)
# flag - флаг завершения игры (адрес)
# используемые регистры: t0 - t5
#
.MACRO print_ending info_x, info_y, flag
    save_all_regs                                           # сохраняем все регистры в стек 
    li t0, \info_x                                          # загружаем координату x
    li t1, \info_y                                          # загружаем координату y
    move_cursor t0, t1                                 
    clear_part_screen                                       # очищаем нижнюю часть экрана
    move_cursor t0, t1                                         
    la t2, \flag                                            # загруажаем адрес flag
    lw t2, 0(t2)                                            # загружаем значение флага
    li t3, 0x0                                              # t3 = 0x0
    li t4, 0x1                                              # t4 = 0x1
    li t5, 0x2                                              # t5 = 0x2
    print_end_line                                          # печатам строку из символов =
    addi t1, t1, 0x1                                        # увеличиваем ординату
    move_cursor t0, t1
    beq t3, t2, print_lose_game                             # если флаг == 0 - проигрыш игры
    beq t4, t2, print_completed_game                        # если флаг == 1 - завершение игры
    beq t5, t2, print_win_game                              # если флаг == 2 - выигрыш иры
    
    print_lose_game:
    print_str lose_msg                                      # печатам сообщение о проигрыше
    j end_print_msg
    print_completed_game:
    print_str end_msg                                       # печатаем сообщение об окончании игры
    j end_print_msg
    print_win_game:
    print_str win_msg                                       # печатаем сообщение о победе
    j end_print_msg

    end_print_msg:
    addi t1, t1, 0x1                                        # увеличиваем ординату
    move_cursor t0, t1
    print_end_line                                          # печатаем строку из символов =
    addi t1, t1, 0x1                                        # увеличиваем оридинату
    move_cursor t0, t1
    load_all_regs                                           # загружаем все регистры из стека
.ENDM

.text                                                       # переключаемся в секцию text
#endif
