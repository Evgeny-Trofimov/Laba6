# Ввод размера матрицы
print "Введите размер матрицы (N): "
n = gets.chomp.to_i

# Создаем квадратную матрицу N x N
matrix = Array.new(n) { Array.new(n) }

# Заполняем матрицу по заданному шаблону
n.times do |i|
  n.times do |j|
    if i == j                # Главная диагональ
      matrix[i][j] = 0
    elsif i < j              # Выше диагонали
      matrix[i][j] = 100 + (n - 1 - j)
    else                     # Ниже диагонали
      matrix[i][j] = 100 + j
    end
  end
end

# Выводим матрицу, заменяя 0 на "000"
matrix.each do |row|
  row.each do |element|
    print element == 0 ? "000\t" : "#{element}\t"
  end
  puts
end
