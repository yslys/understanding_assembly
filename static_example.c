#include <stdio.h>

int not_defined_here;
char message[] = "hello world";
static int invocations = 0;

void hello_world(int increment) {
    static int first_time = 0;
    
    if (increment >= 0) {
        puts(message);
        invocations++;
        fprintf(stderr, "I have printed to the screen %d times\n", invocations);
        hello_world(increment - 1);
    }

    if (first_time == 0) {
        fprintf(stderr, "This is the end of the first invocation of hello_world\n");
        first_time++;
    }
}

int main() {
    hello_world(3);
    return 0;
}
