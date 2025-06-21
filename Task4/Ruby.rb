# Функция для перевода числа в двоичную систему
def to_binary(num)
  return [0] if num == 0
  
  binary = []
  while num > 0
    binary << num % 2 # сохраняем остаток
    num /= 2          # делим число на 2
  end
  binary.reverse      # переворачиваем массив
end

# Функция для подсчета количества единиц (бананов)
def count_bananas(num)
  to_binary(num).count(1)
end

# Основная программа
puts "Введите число: "
n = gets.chomp.to_i

best_pair = [0, n]
max_bananas = count_bananas(0) + count_bananas(n)
max_diff = n

# Перебираем все возможные пары чисел
(1..n/2).each do |a|
  b = n - a
  current_bananas = count_bananas(a) + count_bananas(b)
  
  # Если нашли пару с большим количеством бананов
  # Или такое же количество, но с большей разностью
  if current_bananas > max_bananas || 
     (current_bananas == max_bananas && (b - a) > max_diff)
    max_bananas = current_bananas
    best_pair = [a, b]
    max_diff = b - a
  end
end

# Выводим результат
puts "#{best_pair.first} #{best_pair.last}"
