/* brainfuck.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAPE_SIZE 65536
#define STACK_SIZE 256

char *read_file(const char *filename);
void build_jump_map(const char *code, int *jumps);
void execute_program(const char *code, int *jumps);

int main(int argc, char *argv[]) {
    if(argc < 2) {
        printf("Usage: %s <FILE>\n", argv[0]);
        return 1;
    }

    char *code = read_file(argv[1]);
    int *jumps = calloc(strlen(code), sizeof(int));

    build_jump_map(code, jumps);
    execute_program(code, jumps);

    if(code) free(code);
    if(jumps) free(jumps);
    return 0;
}

char *read_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if(!file) {
        fprintf(stderr, "Error: Could not open file %s\n", filename);
        exit(1);
    }

    fseek(file, 0, SEEK_END);
    long long file_size = ftell(file);
    rewind(file);
    char *code = malloc(file_size + 1);

    if(fread(code, 1, file_size, file) == 0) {
        fprintf(stderr, "Error: Could not read file contents\n");
        fclose(file);
        free(code);
        exit(1);
    }

    fclose(file);
    code[file_size] = '\0';
    return code;
}

void build_jump_map(const char *code, int *jumps) {
    int stack[STACK_SIZE], stk = 0;
    long long index = -1;

    while(code[++index] != '\0') {
        if(code[index] == '[') {
            if(stk >= STACK_SIZE) {
                fprintf(stderr, "Error: Stack overflow building jump map\n");
                exit(1);
            }
            stack[stk++] = index;
        } else if(code[index] == ']') {
            if(stk <= 0) {
                fprintf(stderr, "Error: Stack underflow building jump map\n");
                exit(1);
            }
            int start = stack[--stk];
            jumps[start] = index;
            jumps[index] = start;
        }
    }
    if(stk != 0) {
        fprintf(stderr, "Error: Unmatched brackets in code\n");
        exit(1);
    }
}

void execute_program(const char *code, int *jumps) {
    unsigned char tape[TAPE_SIZE], *ptr = tape;
    size_t pc = -1;
    while(code[++pc] != '\0') {
        switch(code[pc]) {
        case '>': ++ptr; break;
        case '<': --ptr; break;
        case '+': ++*ptr; break;
        case '-': --*ptr; break;
        case '.': putchar(*ptr); break;
        case ',': *ptr = getchar(); break;
        case '[': if(!*ptr) pc = jumps[pc]; break;
        case ']': if(*ptr) pc = jumps[pc]; break;
        }
    }
}
