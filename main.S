#
# Игра Змейка
# здесь реализован главный цикл управления программой
#

#include "graphics.S"
#include "debug.S"
#include "parse_data.S"

.global main

.section .rodata
.equ ROWS    , 25                                                       # количество строк
.equ COLUMNS , 80                                                       # количество столбцов
.equ SNAKE_LEN, 5                                                       # начальная длина змеи
.equ STEP     , 4                                                       # шаг, с которым нужно идти по массиву координат
.equ INFO_Y, 26                                                         # координата y для вывода правил
.equ INFO_X, 1                                                          # координаат x для вывода правил
.equ SCORE_X, 1                                                         # координата x для вывода очков
.equ SCORE_Y, 30                                                        # координата y для вывода очков
.equ INVITE_Y, 31                                                       # координата y для приглашения к вводу
.equ INVITE_X, 1                                                        # координата x для приглашения к вводу
.equ MAX_SCORES, 10                                                     # максимальное число очков

.section .data
delta_x: .word 0x0                                                      # приращение по оси x
delta_y: .word -1                                                       # приращение по оси y
head_x: .word 40, 40, 40, 40 ,40                                        # координаты x каждой части змеи начиная с головы
head_y: .word 12, 13, 14, 15, 16                                        # координаты y каждой части змеи начиная с головы
apple_x: .word 0x0                                                      # координата x яблока
apple_y: .word 0x0                                                      # координата y яблока
flag: .word 0x1                                                         # флаг столкновения со стенкой или с телом
apple_flag: .word 0x1                                                   # флаг генерации позиции яблока
seed: .word 123456789                                                   # зерно для генерации случайных чиел
scores: .word 0x0                                                       # очки игрока

.text
main:
    init_board ROWS, COLUMNS, INFO_X, INFO_Y                            # инициализируем игровое поле
    li t0, 0x0                                                          # t0 - нажатая клавиша
    li t1, ' '                                                          # t1 = ' '
    li t2, 0x1                                                          # t2 = 0x1 (флаг)
    la t4, flag                                                         # загружаем адрес flag
    #init_seed seed                                                      # инициализируем зерно

    main_loop:
    print_scores SCORE_X, SCORE_Y, scores, MAX_SCORES                   # вывод очков игрока за съеденные яблоки
    lw t3, 0(t4)                                                        # загружаем в t3 флаг
    beq t0, t1, end_main_loop                                           # если нажат пробел - выход из игры
    bne t2, t3, end_main_loop
    generating_apple_pos apple_x, apple_y, apple_flag, seed, head_x, head_y
    print_apple apple_x, apple_y                                        # печатаем яблоко
    print_snake head_x, head_y, STEP, SNAKE_LEN                         # печатаем змею
    print_invite INVITE_X, INVITE_Y                                     # приглашаем пользователя считать клавишу
    read_key t0                                                         # считываем клавишу
    clear_prev_line                                                     # очищает предыдущую строку
    clear_snake head_x, head_y, STEP, SNAKE_LEN                         # удаляем змею
    clear_apple apple_x, apple_y                                        # удаляем яблоко 
    move_snake t0, head_x, head_y, STEP, SNAKE_LEN, delta_x, delta_y    # обновляем координаты змеи
    collisions_checking head_x, head_y, STEP, SNAKE_LEN, flag, ROWS, COLUMNS
    eat_apple_checking head_x, head_y, apple_x, apple_y, apple_flag     # обработка взаимодействия змеи с яблоком
    update_scores apple_flag, scores                                    # обновление очков
    check_win scores, MAX_SCORES, flag                                  # проверка на выигрыш
    j main_loop

    end_main_loop: 
    print_ending INFO_X, INFO_Y, flag                                   # печатаем завершение игры
    j exit                                                              # завершаем программу
exit:
    li a0, 0x0
    ret
      
