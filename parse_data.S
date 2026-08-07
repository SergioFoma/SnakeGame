#
# обработка нажатия клавиши и изменение положения змеи
#

#ifndef PARSE_DATA_S_
#define PARSE_DATA_S_

.section .rodata
.equ COUNT, 0x2												# количество считываемых символов
.equ MULT, 25173                                            # множитель в конгруэнтном методе
.equ OFFSET, 13849                                          # приращение в конгруэнтном методе
.equ MOD, 65536                                             # модуль в конгруэнтном методе

.section .data
user_answer: .byte 0x0, 0x0									# выделяем память под считываемые символы

#
# считывает нажатую пользователем клавишу
# res - считанная клавиша (регистр)
# используемые регистры: a0, a1, a2, a7, t6
#
.MACRO read_key res
	li a0, 0x0												# файловый дескриптор stdin
	la a1, user_answer										# загружаем адрес буфера для чтения
	li a2, COUNT											# количество считываемых байт
	li a7, 0x3F												# номер системного вызова read
	ecall													# вызов linux 
	la t6, user_answer										# загружаем адрес буфера
	lb \res, 0(t6)											# загружаем первый байт как беззнаковый
	li a0, 0x0												# файловый дескриптор stdin
	li a1, 0x540B											# флаг TCFLSH (очистка буфера)
	li a2, 0x0												# 0x0 - файловый дескриптор очищаемого буфера
	li a7, 0x1D												# номер системного вызова ioctl
	ecall
.ENDM

#
# обновляет координаты змеи
# key - нажатая клавиша (регистр)
# head_x - массив с координатами x (адрес)
# head_y - массив с координатами y (адрес)
# step - размер одного элемента в массиве в байтах (константа)
# snake_len - длина змеи (константа)
# delta_x - изменение координаты по оси x (адрес)
# delta_y - изменение координаты по оси y (адрес)
# используемые регистры: t0 - t6, s1 - s8 
#
.MACRO move_snake key, head_x, head_y, step, snake_len, delta_x, delta_y

	save_all_regs											# сохранить все регистры в стеке
	mv t0, \key												# сохраняем нажатую клавишу
	li t6, ' '												# t6 = ' '
	beq t0, t6, end											# если нажат пробел - завершение игры
	li t1, 0x0												# счетчик
	la t2, \head_x											# загружаем в t2 адрес массива
	la t3, \head_y											# загружаем в t3 адрес массива
	li t4, \step											# t4 = step
	li t5, \snake_len										# t5 = snake_len
	addi t6, t5, -1											# t6 = snake_len - 1
	start_move:
	bgeu t1, t6,  end_move									# если индекс >= длина - 1 - завершаем перемещение
	mv s1, t6												# s1 = snake_len - 1
	sub s1, s1, t1											# s1 = snake_len - 1 - index
	mul s1, s1, t4											# s1 = (snake_len - 1 - index) * 4 byte
	add s2, t2, s1											# массив + смещение
	add s3, t3, s1											# массив + смещение
	sub s4, s1, t4											# смещение - step (предыдущий элемент)
	add s5, t2, s4											# массив + смещение - step
	add s6, t3, s4											# массив + смещение - step
	lw s7, 0(s5)											# координата x предыдущего элемента
	lw s8, 0(s6)											# координата y предыдущего элемента
	sw s7, 0(s2)											# обновляем координату x текущего элемента
	sw s8, 0(s3)											# обновляем координату y текущего элемента
	addi t1, t1, 0x1										# индекс += 1
	j start_move
	
	end_move:
	li t6, 'a'												# t6 = 'a'
	beq t0, t6, move_left									# если нажата 'a' - перместить влево
	li t6, 'w'											 	# t6 = 'w'
	beq t0, t6, move_straight								# если нажата 'w' - переместить прямо
	li t6, 'd'												# t6 = 'd'
	beq t0, t6, move_right									# если нажата 'd' - переместить вправо
	j move_straight											# нажата другая клавиша, не двигать голову

	move_left:
	la t0, \delta_x											# загружаем адрес delta_x в t0
	la t1, \delta_y											# загружаем адрес delta_y в t1
	lw t4, 0(t0)											# t4 = координата x головы
	lw t5, 0(t1)											# t5 = координата y головы
	sw t5, 0(t0)											# swap координат
	sub t4, x0, t4											# поворот - это смена знака
	sw t4, 0(t1)											# swap координат
	j move_straight
	move_right:
	la t0, \delta_x											# загружаем адрес delta_x в t0
	la t1, \delta_y											# загружаем адрес delta_y в t1
	lw t4, 0(t0)											# t4 = координата x головы
	lw t5, 0(t1)											# t5 = координата y головы
	sw t4, 0(t1)											# swap координат
	sub t5, x0, t5											# поворт - это смена знака
	sw t5, 0(t0)											# swap координат
	j move_straight				
	move_straight:
	lw s1, 0(t2)											# загружаем в s1 координату x головы
	lw s2, 0(t3)											# загружаем в s2 y координату головы
	la t0, \delta_x											# загружаем в t0 адрес delta_x
	la t1, \delta_y											# загружаем в t1 адрес delta_y
	lw t4, 0(t0)											# загружаем в t4 значение delta_x
	lw t5, 0(t1)											# загружаем в t5 значение delta_y
	add s1, s1, t4											# прибавляем к x головы delta_x
	add s2, s2, t5											# прибавляем к y головы delta_y
	sw s1, 0(t2)											# обновляем координату x головы
	sw s2, 0(t3)											# обновляем координату y головы
	end:
	load_all_regs											# загрузить все регистры из стека
.ENDM

#
# проверка на столкновение
# head_x - массив с координатами x (адрес)
# head_y - массив с координатами y (адрес)
# step - размер одного элемента в байтах (константа)
# snake_len - длина змеи (константа)
# flag - флаг на столкновение (адрес)
# rows - количество строк (константа)
# columns - количество столбцов (константа)
# используемые регистры: t0 - t6, s1 - s6
#
.MACRO collisions_checking head_x, head_y, step, snake_len, flag, rows, columns

	save_all_regs											# сохраняем все регистры в стек
	la t0, \head_x											# загружаем адрес массива
	la t1, \head_y											# загружаем адрес массива
	lw t2, 0(t0)											# t2 = координата x головы
	lw t3, 0(t1)											# t3 = координата y головы
	li t4, 0x1												# t4 = 0x1
	li t5, \rows											# t5 = rows
	li t6, \columns											# t6 = columns
	beq t2, t4, collision									# если x головы равна 1 - столкновение
	beq t2, t6, collision									# если x головы равна columns - столкновение 
	beq t3, t4, collision									# если y головы равна 1 - столкновение
	beq t3, t5, collision									# если y головы равна rows - столкновение
	li t4, 0x0												# t4 = 0x0										
	li t5, \snake_len										# t5 = snake_len
	addi t5, t5, -1											# t5 = snake_len - 1
	li s6, 0x1												# s6 = 0x1
	start_checking:
	bgeu t4, t5, end_checking								# если индекс >= длина змеи - 1, то конец цикла
	addi t0, t0, \step										# смещаем указатель на массив
	addi t1, t1, \step										# смещаем указатель на массив
	lw s1, 0(t0)											# загружаем в s1 первый элемент в массиве
	lw s2, 0(t1)											# загружаем в s2 первый элемент в массиве
	xor s3, s1, t2											# если s1 == t2, то s3 = 0
	seqz s3, s3												# если s3 == 0, s3 = 1
	xor s4, s2, t3											# если s2 == t3, то s4 = 0
	seqz s4, s4												# если s4 == 0, то s4 = 1
	and s5, s3, s4											# если s3 == 1, s4 == 1, то и s5 = 1
	beq s5, s6, collision									# если s5 == s6 - столкновение
	addi t4, t4, 0x1
	j start_checking
	end_checking:
	j end_collision

	collision:
	li t0, 0x0												# t0 = 0x0
	la t1, \flag											# загружаем адрес flag в регистр t1
	sw t0, 0(t1)											# сохраняем значение t0 по адресу в t1
	j end_collision
	end_collision:
	load_all_regs
.ENDM

#
# инициализация зерна
# seed - зерно размером 32 бита (адрес)
# используемые регистры: 
#
.MACRO init_seed seed
    save_all_regs                                          # сохраняем все регистры в стек
    la t0, \seed                                           # загруажем адрес зерна
    rdtime a0                                              # записывает 64 битное значение текущего времени
    sw a0, 0(t0)                                           # записываем младшие 32 бита по адресу seed
    load_all_regs                                          # загруажаем все регистры из стека
.ENDM 

#
# генерация позиции яблока
# apple_x - координата x яблока (адрес)
# apple_y - координата y яблока (адрес)
# apple_flag - флаг генерации (адрес)
# seed - зерно (адрес)
# head_x - массив с координатами x частей змеи (адрес)
# head_y - массив с координатами y (адрес)
# используемые регистры: t0 - t6, s1 - s11, a0 - a2
#
.MACRO generating_apple_pos apple_x, apple_y, apple_flag, seed, head_x, head_y

    save_all_regs                                          # сохраняем все регистры в стек
    la t0, \apple_flag                                     # загружаем адрес apple_flag в t0
    lw t1, 0(t0)                                           # загружаем значение флага в t1
    li t2, 0x1                                             # t2 = 0x1
    bne t1, t2, not_generating                             # если флаг != 0x1 - не генерируем
    li t1, MULT                                            # загружаем множитель
    li t2, OFFSET                                          # загружаем сдвиг
    li t3, MOD                                             # загружаем модуль
    la t4, \seed                                           # загружаем адрес зерна
    lw t5, 0(t4)                                           # загружаем значение зерна
    li s1, ROWS                                            # загружаем количество строк
    li s2, COLUMNS                                         # загружаем количество столбцов
    li s5, 0x1                                             # s5 = 0x1
    li s6, 0x0                                             # s6 = 0x0
    generating_loop:
    mul t6, t1, t5                                         # t6 = множитель * зерно
    add t6, t6, t2                                         # t6 = множитель * зерно + смещение
    rem t6, t6, t3                                         # t6 = (множитель * зерно + смещение) % модуль
    rem s3, t6, s1                                         # координата y
    mul t6, t1, t6                                         # t6 = множитель * новое_зерно
    add t6, t6, t2                                         # t6 = множитель * новое_зерно + смещение
    rem t6, t6, t3                                         # t6 = (множитель * новое_зерно + смещение) % модуль
    rem s4, t6, s2                                         # координата x
    mv t5, t6                                              # обновляем зерно
    beq s3, s5, generating_loop                            # если y == 0x1 - снова генерируем
    beq s3, s1, generating_loop                            # если y == rows - снова генерируем
    beq s4, s5, generating_loop                            # если x == 0x1 - снова генерируем
    beq s4, s2, generating_loop                            # если x == columns - снова генерируем
    beq s3, s6, generating_loop                            # если y == 0x0 - снова генерируем
    beq s4, s6, generating_loop                            # если x == 0x0 - снова генерируем
    la s7, \head_x                                         # загружаем адрес head_x в регистр s7
    la s8, \head_y                                         # загружаем адрес head_y в регистр s8
    li s9, 0x0                                             # счетчик
    li s10, SNAKE_LEN                                      # длина змеи
    li s11, 0x1                                            # s1 = 0x1
    start_checking_loop:
    bgeu s9, s10, end_generating_loop                      # если индекс >= длина змеи - заканчиваем цикл
    lw a0, 0(s7)                                           # загружаем координату x
    xor a0, a0, s4                                         # проверяем на равенство head_x и apple_x
    seqz a0, a0                                            # если a0 == 0, то a0 = 1
    lw a1, 0(s8)                                           # загружаем координату y
    xor a1, a1, s3                                         # проверяем на равенство head_y и apple_y
    seqz a1, a1                                            # если a1 == 0, то a1 = 1
    and a2, a0, a1                                         # a2 = a0 & a1
    beq a2, s11, generating_loop                           # если координаты яблока совпали с координатами головы
    addi s7, s7, STEP                                      # сдвигаем адрес на размер элемента
    addi s8, s8, STEP                                      # сдвигаем адрес на размер элемента
    addi s9, s9, 0x1                                       # увеличиваем счетчик на 1
    j start_checking_loop

    end_generating_loop:
    li t1, 0x0                                             # t1 = 0x0
    sw t1, 0(t0)                                           # загруажем по адресу apple_flag значение t1
    la t0, \apple_x                                        # загруажем в t0 адрес apple_x
    la t1, \apple_y                                        # загружаем в t1 адрес apple_y
    sw s4, 0(t0)                                           # загружаем координату x по адресу apple_x
    sw s3, 0(t1)                                           # загружаем координату y по адресу apple_y
    sw t5, 0(t4)                                           # обновляем зерно
    not_generating:
    load_all_regs
.ENDM

#
# обработка взаимодействия змеи с яблоком
# head_x - массив с координатами x частей змеи (адрес)
# head_y - массив с координатами y частей змеи (адрес)
# apple_x - координата x яблока (адрес)
# apple_y - координата y яблока (адрес)
# apple_flag - флаг на изменение положения яблока (адрес) 
# используемые регистры: t0 - t6, s1 - s5
#
.MACRO eat_apple_checking head_x, head_y, apple_x, apple_y, apple_flag
    
    save_all_regs                                          # сохраняем все регистры в стек 
    la t0, \head_x                                         # загрузка адреса head_x
    la t1, \head_y                                         # загрузка адреса head_y
    la t2, \apple_x                                        # загружаем в t2 адрес apple_x
    lw t2, 0(t2)                                           # загружаем в t2 координату x яблока
    la t3, \apple_y                                        # загружаем в t3 адрес apple_y
    lw t3, 0(t3)                                           # загружаем в t3 координату y яблока
    li s1, 0x0                                             # s1 = 0x0 - счетчик
    li s2, SNAKE_LEN                                       # s2 хранит длину змеи
    eat_apple_loop:
    bgeu s1, s2, end_eat_loop                              # если s1 >= длина змеи - выходим из цикла
    lw s3, 0(t0)                                           # загружаем координату x змеи
    lw s4, 0(t1)                                           # загружаем координату y змеи
    xor t4, s3, t2                                         # t4 = 0, если s3 == t2
    seqz t4, t4                                            # t4 = 1, если t4 == 0
    xor t5, s4, t3                                         # t5 = 0, если s4 == t3
    seqz t5, t5                                            # t5 = 1, если t5 == 0
    and t6, t4, t5                                         # t6 = t5 & t4
    li s5, 0x1                                             # s1 = 0x1
    beq t6, s5, change_flag
    addi t0, t0, STEP                                      # сдвишаем указатель на массив
    addi t1, t1, STEP                                      # сдвигаем указатель на массив
    addi s1, s1, 0x1                                       # увеличиваем индекс
    j eat_apple_loop
    end_eat_loop:
    j not_change_flag
    change_flag:
    li s1, 0x1
    la t0, \apple_flag                                     # загружаем в t0 адрес apple_flag
    sw s1, 0(t0)                                           # изменяем значение флага на 0x1
    not_change_flag:
    load_all_regs                                          # загружаем все регистры из стека
.ENDM


.text
#endif
