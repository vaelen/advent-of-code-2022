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
// X = 1, Y = 2, Z = 3
// Loss = 0, Draw = 3, Win = 6


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
    //  Rock (A or X) = 1
    //  Paper (B or Y) = 2
    //  Scissors (C or Z) = 3
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
    LDR     R0,[R9, #2]     // Load third byte
    CMP     R0, #'X'
    MOVEQ   R2, #1
    CMP     R0, #'Y'
    MOVEQ   R2, #2
    CMP     R0, #'Z'
    MOVEQ   R2, #3

    ADD     R12, R12, R2    // Add our play to the total score

    // Find a winner
    CMP     R1, R2
    BEQ     draw
    CMP     R1,#2
    BGT     scissors
    BEQ     paper

rock:
    CMP     R2,#2
    ADDEQ   R12, R12, #6 // Add 6 if we won
    B       readline    // Loop

paper:
    CMP     R2,#3
    ADDEQ   R12, R12, #6 // Add 6 if we won
    B       readline    // Loop

scissors:
    CMP     R2,#1
    ADDEQ   R12, R12, #6 // Add 6 if we won
    B       readline    // Loop

draw:
    ADD     R12, R12, #3     // Draw
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
