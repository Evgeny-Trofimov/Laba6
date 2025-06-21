#include <iostream>
#include <utility> // для pair
#include <vector>
#include <algorithm> // для reverse

using namespace std;

// Функция для перевода числа в двоичную систему
vector<int> toBinary(int num) {
    vector<int> binary;
    
    if (num == 0) {
        binary.push_back(0);
        return binary;
    }
    
    while (num > 0) {
        binary.push_back(num % 2); // сохраняем остаток
        num /= 2;                // делим число на 2
    }
    
    reverse(binary.begin(), binary.end()); // переворачиваем массив
    return binary;
}

// Функция для подсчета количества единиц (бананов) через двоичное представление
int countBananas(int num) {
    vector<int> binary = toBinary(num);
    int count = 0;
    for (int bit : binary) {
        if (bit == 1) count++;
    }
    return count;
}

int main() {
    cout << "Введите число: ";
    int N;
    cin >> N; 
    
    pair<int, int> bestPair = {0, N}; // Начальная пара (0, N)
    int maxBananas = countBananas(0) + countBananas(N);
    int maxDiff = N; // Разность чисел в паре

    // Перебираем все возможные пары чисел
    for (int a = 1; a <= N/2; ++a) {
        int b = N - a;
        int currentBananas = countBananas(a) + countBananas(b);
        
        // Если нашли пару с большим количеством бананов
        // Или такое же количество, но с большей разностью
        if (currentBananas > maxBananas || 
            (currentBananas == maxBananas && (b - a) > maxDiff)) {
            maxBananas = currentBananas;
            bestPair = {a, b};
            maxDiff = b - a;
        }
    }

    // Выводим результат
    cout << bestPair.first << " " << bestPair.second << endl;
    return 0;
}
