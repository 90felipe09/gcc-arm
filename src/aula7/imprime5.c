#include<stdio.h>
#include<stdlib.h>

void imprime(N, A, B, C, D) {
  if (N<0) {
    return;
  }
  printf("numero = %d\n", N);
  printf("A = %d\n", A);
  printf("B = %d\n", B);
  printf("C = %d\n", C);
  printf("D = %d\n", D);
  imprime(N-1, A, B, C, D);
}


int main(void ) {
     imprime(5, 1, 2, 3, 4);
}
