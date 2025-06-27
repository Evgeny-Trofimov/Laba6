EPSILON = 1e-6

def gaussian_elimination(a, b)
  n = a.size
  
  (0...n).each do |i|
    max_row = i
    (i+1...n).each do |k|
      max_row = k if a[k][i].abs > a[max_row][i].abs
    end

    a[i], a[max_row] = a[max_row], a[i]
    b[i], b[max_row] = b[max_row], b[i]
    
    (i+1...n).each do |k|
      factor = a[k][i] / a[i][i]
      (i...n).each { |j| a[k][j] -= factor * a[i][j] }
      b[k] -= factor * b[i]
    end
  end
  
  x = Array.new(n, 0)
  
  (n-1).downto(0) do |i|
    x[i] = b[i]
    (i+1...n).each { |j| x[i] -= a[i][j] * x[j] }
    x[i] /= a[i][i]
  end
  
  x
end

def seidel_method(a, b, epsilon = EPSILON, max_iterations = 100)
  n = a.size
  x = Array.new(n, 0.0)
  x_prev = Array.new(n, 0.0)
  iteration = 0
  error = 0.0

  begin
    x_prev = x.dup
    
    (0...n).each do |i|
      sum = 0.0
      (0...n).each do |j|
        sum += a[i][j] * (j < i ? x[j] : x_prev[j]) if j != i
      end
      x[i] = (b[i] - sum) / a[i][i]
    end

    error = 0.0
    (0...n).each { |i| error = [error, (x[i] - x_prev[i]).abs].max }
    
    iteration += 1
  end while error > epsilon && iteration < max_iterations

  if iteration == max_iterations
    puts "Метод Зейделя не сходится"
    x
  else
    puts "Метод Зейделя сошелся за #{iteration} итераций"
    x
  end
end

def print_results(x, method_name)
  puts "\nРезультаты решения методом #{method_name}:"
  puts "+-----+-------------+-------------+-------------+-------------+"
  puts "|  N  |     x1      |     x2      |     x3      |     x4      |"
  puts "+-----+-------------+-------------+-------------+-------------+"
  puts "|  1  | %11.8f | %11.8f | %11.8f | %11.8f |" % [x[0], x[1], x[2], x[3]]
  puts "+-----+-------------+-------------+-------------+-------------+\n\n"
end

def main
  a = [
    [-18.0,  -0.04,  0.21,  0.91],
    [-0.09,  -1.23,  -0.23, 0.25],
    [-0.13, -0.23,  0.8,   -0.21],
    [-1.04,  -1.31,  0.06,  0.15]
  ]

  b = [-1.24, -1.04, 2.56, 0.91]

  is_dominant = true
  
  (0...4).each do |i|
    sum = 0.0
    (0...4).each { |j| sum += a[i][j].abs if j != i }
    
    if a[i][i].abs <= sum
      is_dominant = false
      puts "Строка #{i+1} не удовлетворяет условию диагонального преобладания"
    end
  end
  
  puts "Внимание: матрица не имеет диагонального преобладания!" unless is_dominant

  x_gauss = gaussian_elimination(a, b)
  print_results(x_gauss, "Гаусса")

  x_seidel = seidel_method(a, b)
  print_results(x_seidel, "Зейделя")
end

main
