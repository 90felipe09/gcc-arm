#include<stdio.h>
#include<stdlib.h>

void imprime(N) {
  int lixo;
  lixo ++;
  if (N<0) {
    return;
  }
  printf("numero = %d\n", N);
  imprime(N-1);
}


int main(void ) {
     imprime(5);
}
