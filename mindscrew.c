/* mindscrew.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>



typedef unsigned char cell;
/* typedef unsigned short cell; */
/* typedef unsigned long cell; */
/* typedef unsigned long long cell; */

#define TAPE_SIZE 65536
#define STACK_SIZE 256

char* read_file(const char* filename);
void build_jump_map(const char* code, int* subs, int* jumps);
void execute_program(const char* code, int* subs, int* jumps);
void free_resources(char* code, int* subs, int* jumps);

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <FILE>\n", argv[0]);
        return 1;
    }

    char* code = read_file(argv[1]);
    int* subs = calloc(strlen(code), sizeof(int));
    int* jumps = calloc(strlen(code), sizeof(int));
    build_jump_map(code, subs, jumps);
    execute_program(code, subs, jumps);

    free_resources(code, subs, jumps);
    return 0;
}

char* read_file(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Error: Could not open file %s\n", filename);
        exit(1);
    }

    fseek(file, 0, SEEK_END);
    long long file_size = ftell(file);
    rewind(file);
    char* code = malloc(file_size + 1);

    if (fread(code, 1, file_size, file) == 0) {
        fprintf(stderr, "Error: Could not read file contents\n");
        fclose(file); free(code); exit(1);
    }

    fclose(file);
    code[file_size] = '\0';
    return code;
}

void build_jump_map(const char* code, int* subs, int* jumps) {
    int stack[STACK_SIZE], stk = 0, routine = 0;
    long long index = -1;

    char c;
    while ((c = code[++index]) != '\0') {
        if (c == '{' || c == '[' || c == '(') {
            if (stk >= STACK_SIZE) {
                fprintf(stderr, "Error: Stack overflow while building jump map\n");
                exit(1);
            }
            stack[stk++] = index;
            if (c == '{') {
                subs[routine++] = index;
            }
        } else if (c == '}' || c == ']' || c == ')') {
            if (stk <= 0) {
                fprintf(stderr, "Error: Stack underflow while building jump map\n");
                exit(1);
            }
            int start = stack[--stk];
            jumps[start] = index;
            jumps[index] = start;
        }
    }
    if (stk != 0) {
        fprintf(stderr, "Error: Unmatched bracket in code\n");
        exit(1);
    }
}

void execute_program(const char* code, int* subs, int* jumps) {
    int stack[STACK_SIZE], stk = 0, ptr = 0;
    long long counter = 0;

    cell acc = 0, tape[TAPE_SIZE] = { 0 };
    while (code[counter] != '\0') {
        switch (code[counter]) {
        case '>': ptr = ptr == TAPE_SIZE - 1 ? 0 : ptr + 1; break;
        case '<': ptr = ptr == 0 ? TAPE_SIZE - 1 : ptr - 1; break;
        case '+': tape[ptr]++; break;
        case '-': tape[ptr]--; break;
        case '.': printf("%c", tape[ptr]); break;
        case ',': scanf("%c", &tape[ptr]); break;
        case '[': if (!tape[ptr]) counter = jumps[counter]; break;
        case ']': if (tape[ptr]) counter = jumps[counter]; break;
        case '(': if (!acc) counter = jumps[counter]; break;
        case ')': if (acc) counter = jumps[counter]; break;
        case '{': counter = jumps[counter]; break;
        case '}':
            if (stk <= 0) {
                fprintf(stderr, "Error: Stack underflow during execution\n");
                exit(1);
            }
            counter = stack[--stk];
            break;
        case ':': {
            cell swp = acc;
            acc = tape[ptr];
            tape[ptr] = swp;
            break;
        }
        case '!':
            if (stk >= STACK_SIZE) {
                fprintf(stderr, "Error: Stack overflow during execution\n");
                exit(1);
            }
            stack[stk++] = counter;
            counter = subs[acc];
            break;
        }
        counter++;
    }
}

void free_resources(char* code, int* subs, int* jumps) {
    if (code) free(code);
    if (subs) free(subs);
    if (jumps) free(jumps);
}
