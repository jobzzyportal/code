#include <stdio.h>
#include <string.h>
#include <ctype.h>

char input[100];
int i = 0;
int temp = 1;

void newTemp(char *t) {
    sprintf(t, "t%d", temp++);
}

void generate() {
    char op1[10], op2[10], res[10];

    while (input[i] != '\0') {
        if (input[i] == '*' || input[i] == '/') {
            char operator = input[i];

            op1[0] = input[i - 1];
            op1[1] = '\0';

            op2[0] = input[i + 1];
            op2[1] = '\0';

            newTemp(res);

            printf("%s = %s %c %s\n", res, op1, operator, op2);

            input[i - 1] = res[0];
            input[i] = ' ';
            input[i + 1] = ' ';
        }
        i++;
    }

    i = 0;

    while (input[i] != '\0') {
        if (input[i] == '+' || input[i] == '-') {
            char operator = input[i];

            op1[0] = input[i - 1];
            op1[1] = '\0';

            op2[0] = input[i + 1];
            op2[1] = '\0';

            newTemp(res);

            printf("%s = %s %c %s\n", res, op1, operator, op2);

            input[i - 1] = res[0];
            input[i] = ' ';
            input[i + 1] = ' ';
        }
        i++;
    }
}

int main() {
    printf("Enter expression: ");
    scanf("%s", input);

    generate();

    return 0;
}
