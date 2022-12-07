/*
    MIT License

    Copyright (c) 2022 Andrew Young

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

// Day 2, Part 1 - https://adventofcode.com/2022/day/2


//    Example input:
/*
    A Y
    B X
    C Z
*/
// Scoring
//  A = 1, B = 2, C = 3
//  Loss = 0, Draw = 3, Win = 6
// Meaning of x, Y, and Z
// X = loss
// Y = tie
// Z = win


.global _start
.global exit

.global open_read
.global check_read_error
.global puts
.global read
.global atoi

_start:
    // Store count and max in registers
    MOV     R12, #0 // sum

    // Get program arguments
    POP     {R1}    // number of arguments
    CMP     R1, #2  // check for at least 2 arguments
    BLT     no_arguments
    POP     {R1}    // pointer to first argument (program name)
    POP     {R1}    // pointer to second argument (input file name)

    // Print input filename
    LDR     R0, =path_label
    BL      fputs

    // Open the input file
    MOV     R0, R1
    BL      puts
    BL      open_read
    BL      check_read_error
    CMP     R0, #0  // Check for an error opening the file
    BMI     error
    MOV     R4, R0  // Move file handle from R0 to R4

    // Read a line of data
readline:
    MOV     R10, #0         // loop counter
    LDR     R9, =buffer     // buffer pointer
readline_loop:
    MOV     R0, R4          // file number
    MOV     R1, R9          // buffer pointer
    MOV     R2, #1          // bytes to read
    BL      read            // read byte
    CMP     R0, #0          // Check for EOF
    BLE     readline_done
    LDRB    R8, [R9]        // Load byte that was just read
    CMP     R8, #'\n'       // Check for newline
    BEQ     readline_done
    CMP     R8, #'\r'       // Skip carriage return
    ADDNE   R9, #1          // increase buffer pointer
    ADDNE   R10, #1         // Increase loop counter
    CMP     R10, #5         // Check for the end of the buffer
    BLT     readline_loop
readline_done:
    BL      check_read_error
    MOV     R0,#0           // Put a 0 at the end of the buffer
    STRB    R0,[R9]

    // Check for an empty line, which denotes EOF
    LDR     R9,=buffer      
    LDRB    R0,[R9]
    CMP     R0,#0
    BEQ     done

    // Convert throws to ints for easy comparison
    //  Rock (A)  = 1
    //  Paper (B) = 2
    //  Scissors (C) = 3
    // Registers:
    //  R9 = buffer pointer
    //  R0 = character
    //  R1 = opponent's play
    //  R2 = our play
    LDR     R9,=buffer      // Buffer pointer
    LDRB    R0,[R9]         // Load first byte
    CMP     R0, #'A'
    MOVEQ   R1, #1
    CMP     R0, #'B'
    MOVEQ   R1, #2
    CMP     R0, #'C'
    MOVEQ   R1, #3

    // Win, lose, or draw?
    LDR     R0,[R9, #2]     // Load third byte (win, lose, or draw)
    CMP     R0, #'Z'
    BEQ     win
    CMP     R0, #'X'
    BEQ     lose

draw:
    ADD     R12, R12, #3    // A draw is 3 points
    ADD     R12, R12, R1    // Set our choice to the same as the opponent
    B       readline        // Loop

win:
    ADD     R12, R12, #6    // A win is 6 points
    CMP     R1, #2
    ADDLT   R12, R12, #2    // Paper beats rock
    ADDEQ   R12, R12, #3    // Scissors beat paper
    ADDGT   R12, R12, #1    // Rock beats scissors
    B       readline        // Loop

lose:
    CMP     R1, #2
    ADDLT   R12, R12, #3    // Rock beats scissors
    ADDEQ   R12, R12, #1    // Paper beats rock
    ADDGT   R12, R12, #2    // Scissors beat paper
    B       readline        // Loop

no_arguments:
    LDR     R0,=no_args     // Print a help message
    BL      puts
    B       error

done:
    MOV     R0,R12          // Copy sum to R0
    BL      print_r0
    BL      newline
    MOV     R0, #0          // Return success
    B       exit

error:
    MOV     R0, #1          // Return error
    B       exit

.data

path_label: .asciz "File: "
no_args:    .asciz "Please provide a file name."
buffer:     .byte  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
