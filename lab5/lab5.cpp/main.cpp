//С клавиатуры вводятся размерность N и квадратная матрица размерности NxN и число а.
// Посчитать и вывести суммы элементов больше а, расположенных в верхнем и нижнем треугольниках,
// образуемых диагоналями. Заменить элементы кратные 3 левого треугольника на первую
// сумму, а кратные 5 - на вторую сумму.

#include <iostream>
#include <iomanip>
using namespace std;

int main() {
    cout << "Enter matrix size (<= 10)" << endl;
    int size;
    cin >> size;

    if(size <= 0 || size > 10) {
        cout << "Invalid input!";
        return 0;
    }

    int array [size][size];

    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            array[i][j] = -50 + rand() % 101;
        }
    }

    cout << "Entered matrix:" << endl;

    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            cout << setw(4) << array[i][j];
        }
        cout << endl;
    }

    cout << endl << "Enter a: " << endl;
    int a;
    cin >> a;

    int upperSum = 0, lowerSum = 0;
    int n = 0;

    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            if(j > n) // верхний треугольник
                if(array[i][j] > a)
                    upperSum += array[i][j];

            if(j < n) // нижний треугольник
                if(array[i][j] > a)
                    lowerSum += array[i][j];
        }
        n++;
    }

    cout << "Sum at upper triangle: " << upperSum << endl <<
            "Sum at lower triangle: " << lowerSum << endl;
    n = 0;

    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            if(j > n && array[i][j] % 3 == 0)
                array[i][j] = upperSum;

            if(j < n && array[i][j] % 5 == 0)
                array[i][j] = lowerSum;

            cout << setw(4) << array[i][j];
        }
        n++;
        cout << endl;
    }

    return 0;
}
