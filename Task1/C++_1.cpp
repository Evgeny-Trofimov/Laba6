#include <iostream>       
#include <vector>        
#include <unordered_map>  
#include <random>         

using namespace std;      

// Функция проверки, является ли число простым
bool isPrime(int n) {
    if (n <= 1) return false;  // Числа <= 1 не являются простыми
    for (int i = 2; i * i <= n; ++i) {  // Проверяем делители до корня из n
        if (n % i == 0) return false;   
    }
    return true;  
}

int main() {
    int M, N;  
    cout << "Введите количество строк: ";
    cin >> M;  
    cout << "Введите количество столбцов: ";
    cin >> N;  

    // Создаём матрицу размером M x N, заполненную нулями
    vector<vector<int>> matrix(M, vector<int>(N));

    // Словарь для подсчёта количества вхождений простых чисел (простое число - его кол-во в матрице)
    unordered_map<int, int> primeCount;

    // Настройка генератора случайных чисел
    random_device rd;       
    mt19937 gen(rd());      
    uniform_int_distribution<> dis(0, 50);  

    // Заполняем матрицу случайными числами и выводим её
    for (int i = 0; i < M; ++i) {         // Проход по строкам
        for (int j = 0; j < N; ++j) {     // Проход по столбцам
            matrix[i][j] = dis(gen);      // Записываем случайное число в матрицу
            cout << matrix[i][j] << "\t"; // Выводим число с табуляцией
            if (isPrime(matrix[i][j])) {  // Если число простое
                primeCount[matrix[i][j]]++; // увеличиваем счётчик для этого числа
            }
        }
        cout << endl;  // Переход на новую строку после вывода строки матрицы
    }

    // Поиск самого частого простого числа
    int maxCount = 0;           // Максимальное количество
    int mostFrequentPrime = -1; // Само число (инициализируем -1 как флаг отсутствия)

    // Проходим по всем парам "простое число - его кол-во" в словаре
    for (const auto& [prime, count] : primeCount) {
        if (count > maxCount) {  // Если текущее число встречается чаще,
            maxCount = count;     // обновляем максимум
            mostFrequentPrime = prime;  // и запоминаем число
        }
    }

    // Вывод результата
    if (mostFrequentPrime == -1) {  // Если простых чисел не найдено
        cout << "В матрице нет простых чисел." << endl;
    } else {  // Если нашли
        cout << "Самое частое простое число: " << mostFrequentPrime 
             << " (встречается " << maxCount << " раз(а))." << endl;
    }

    return 0;  
}
