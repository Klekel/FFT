

import numpy as np

N = 8
precision = 0  # Задаем желаемую точность для дробной части
precision_int = 24
B = np.array([1 + 1j, 1024 + 512j, -3 + 1j, 2 - 2j, 1, 128 - 32j, 1, 3])
for n in range(N):
    value = B[n]

    real_value = value.real
    imaginary_value = value.imag

    # Получаем знак и абсолютное значение для дробной и мнимой частей
    if real_value < 0:
        real_sign = '-s'
        real_value = abs(real_value)
    else:
        real_sign = '0'

    if imaginary_value < 0:
        imaginary_sign = '-s'
        imaginary_value = abs(imaginary_value)
    else:
        imaginary_sign = '0'

    real_integer_part = int(real_value)
    real_fractional_part = real_value - real_integer_part
    imaginary_integer_part = int(imaginary_value)
    imaginary_fractional_part = imaginary_value - imaginary_integer_part

    # Преобразуем целую часть и дробную часть для каждой компоненты в двоичный вид
    real_integer_binary = bin(real_integer_part)[2:].zfill(precision_int)
    imaginary_integer_binary = bin(imaginary_integer_part)[2:].zfill(precision_int)

    print('W[', n, ']', B[n])
    print(f"Действительная часть в двоичном виде: {real_sign}{real_integer_binary}")
    print(f"Мнимая часть в двоичном виде: {imaginary_sign}{imaginary_integer_binary}", '\n')




