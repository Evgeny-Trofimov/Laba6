# Функция проверки, является ли число простым
def is_prime(n)
  return false if n <= 1  # Числа <= 1 не являются простыми
  (2..Math.sqrt(n).each do |i|  # Проверяем делители до корня из n
    return false if n % i == 0
  end
  true
end

# Ввод размеров матрицы
print "Введите количество строк: "
m = gets.chomp.to_i
print "Введите количество столбцов: "
n = gets.chomp.to_i

# Создаем матрицу и заполняем случайными числами 0..50
matrix = Array.new(m) { Array.new(n) { rand(0..50) } }
prime_count = Hash.new(0)  # Хэш для подсчета простых чисел

# Выводим матрицу и считаем простые числа
puts "Матрица:"
matrix.each do |row|
  row.each do |val|
    print "#{val}\t"
    prime_count[val] += 1 if is_prime(val)
  end
  puts
end

# Находим самое частое простое число
max_count = 0
most_frequent_prime = nil

prime_count.each do |prime, count|
  if count > max_count
    max_count = count
    most_frequent_prime = prime
  end
end

# Вывод результата
if most_frequent_prime.nil?
  puts "В матрице нет простых чисел."
else
  puts "Самое частое простое число: #{most_frequent_prime} (встречается #{max_count} раз(а))."
end
