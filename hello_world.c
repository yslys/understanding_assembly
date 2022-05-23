#include <stdio.h>
#include <stdlib.h>

void foo2(){
	printf("hi\n");
	return;
}

void foo1(){
	foo2();
	return;
}

int main(){
	foo1();
	return 0;
}
