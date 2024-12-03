# Mindscrew

**Mindscrew** is an extension of **brainfuck** that introduces subroutines and an accumulator.

## Commands

**Mindscrew** inherits all commands from **brainfuck** and extends the command set to the following:

### Tape Manipulation
- **`<`**: Move the pointer the left, wraps around.
- **`>`**: Move the pointer the right, wraps around.
- **`+`**: Increment the current cell.
- **`-`**: Decrement the current cell.

### I/O
- **`.`**: Output the current cell as an ASCII character.
- **`,`**: Input a single ASCII character and store it in the current cell.

### Looping
- **`[`**: Jump forward past the corresponding `]` if the current cell is 0.
- **`]`**: Jump back after the corresponding `[` if the current cell is non-zero.

### Accumulator
- **`(`**: Jump forward past the corresponding `)` if the accumulator is 0.
- **`)`**: Jump back after the corresponding `(` if the accumulator is non-zero.
- **`:`**: Swap the values in the current cell and accumulator.

### Subroutines
- **`{`**: Start defining a subroutine, this command will jump to its end brace if hit during runtime.
- **`}`**: Marks the end of a subroutine, this command will return execution to the calling point during runtime.
- **`!`**: Call a subroutine indexed by the value in the accumulator.

## Subroutines

**Mindscrew** subroutines allow for better code structure, they are defined between `{}` and are indexed incrementally. Each `{` starts a new subroutine, and `}` marks the end. You can call subroutines using the `!` command, which jumps to the subroutine corresponding to the value in the accumulator.

## Implementation details

The official **mindscrew** interpreter `mindscrew.c` is written in C, it's tape size is 65536 bytes, its tape and accumulator are both unsigned 8 bit integers.
On STDIN EOF `,` will return `0`, on the edges of the tape
`>` and `<` will wrap around to the other end of the tape.
There are checks in place to error out if the stack overflows or underflows.

## Examples

### Example 1: Basic subroutine call
```bf
{++++ ++++}   subroutine_0 adds 8 to the current cell
!!!! !!!!.    call subroutine_0 8 times and output '@' ASCII 64
```

### Example 2: Using loops and subroutines to multiply
```bf
{++++ ++++}   subroutine_0 adds 8 to the current cell
!             add 8 to cell_0
[->!<]        loop that adds 8 to cell_1 by cell_0 times
>+.           move to cell_1, add 1 and output 'A' ASCII 65
```

### Example 3: Accumulator-based conditional
```bf
++++:       set acc to 4
(:-:++++)   add 4 to cell_0 until acc is 0 making cell_0 16
:           swap acc with cell_0 acc = 16 cell 0 = 0
(:-:++++)   add 4 to cell_0 until acc is 0 making cell_0 64
.           output '@' ASCII 64
```

### Example 4: Multiple subroutines
```bf
{++++}   subroutine_0 add 4
{----}   subroutine_1 subtract 4
:+:      increment the accumulator acc = 1
!        call subroutine_1 cell_0 is now ¯4, or 252
```
