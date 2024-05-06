

import numpy as np

N = 8
W = np.exp(1j * (-2 * np.pi / N) )
precision = 16  # Задаем желаемую точность для дробной части
precision_int = 1
for n in range(int(N / 2)):
    B = W ** n

    real_value = B.real
    imaginary_value = B.imag

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
    real_fractional_binary = bin(int(real_fractional_part * (2 ** precision)))[2:].zfill(precision)
    imaginary_fractional_binary = bin(int(imaginary_fractional_part * (2 ** precision)))[2:].zfill(precision)

    print('W[', n, ']', B)
    print(f"Действительная часть в двоичном виде: {real_sign}{real_integer_binary}{real_fractional_binary}")
    print(f"Мнимая часть в двоичном виде: {imaginary_sign}{imaginary_integer_binary}{imaginary_fractional_binary}", '\n')




