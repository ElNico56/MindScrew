# brainfuck.nim

import os

const TAPE_SIZE = 65536

proc buildJumpMap(code: string): seq[int] =
    result = newSeq[int](code.len)
    var stack: seq[int] = @[]
    for index, ch in code:
        if ch == '[':
            stack.add(index)
        elif ch == ']':
            if stack.len == 0:
                quit "Error: Stack underflow building jump map :c", 1
            let start = stack.pop()
            result[start] = index
            result[index] = start
    if stack.len != 0:
        quit "Error: Unmatched brackets in code :c", 1

proc executeProgram(code: string, jumps: seq[int]) =
    var tape: array[TAPE_SIZE, uint8]
    var bfptr: int = 0
    var pc: int = 0
    while pc < code.len:
        case code[pc]
        of '>': inc bfptr
        of '<': dec bfptr
        of '+': inc tape[bfptr]
        of '-': dec tape[bfptr]
        of '.': stdout.write chr(tape[bfptr])
        of ',': tape[bfptr] = uint8(stdin.readChar())
        of '[': (if tape[bfptr] == 0: pc = jumps[pc])
        of ']': (if tape[bfptr] != 0: pc = jumps[pc])
        else: discard
        inc pc

when isMainModule:
    if paramCount() < 1:
        echo "Usage: ", getAppFilename(), " <FILE>"
        quit 1
    let filename = paramStr(1)
    if not fileExists(filename):
        quit "Error: Could not open file " & filename, 1
    let code = readFile(filename)
    let jumps = buildJumpMap(code)
    executeProgram(code, jumps)
