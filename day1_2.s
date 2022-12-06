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

// Day 1, Part 2 - https://adventofcode.com/2022/day/1


//    Example input:
/*
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
*/

// Problem Description
/*
    Find the top three Elves carrying the most Calories. How many Calories are those Elves carrying in total?
*/

// Solution
/*
    This is effectively the same as the last problem, except that we need to keep track of the top three values.
    Added steps are:
        1. When checking if a sum is larger than max, check to see if it is larger than any of the max values.
        2. Sum the max values at the end.
*/        

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
    MOV     R11, #0 // max1
    MOV     R10, #0 // max2
    MOV     R9, #0  // max3

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
    MOV     R8, #0         // loop counter
    LDR     R7, =buffer     // buffer pointer
readline_loop:
    MOV     R0, R4          // file number
    MOV     R1, R7          // buffer pointer
    MOV     R2, #1          // bytes to read
    BL      read            // read byte
    CMP     R0, #0          // Check for EOF
    BLE     readline_done
    LDRB    R6, [R7]        // Load byte that was just read
    CMP     R6, #'\n'       // Check for newline
    BEQ     readline_done
    CMP     R6, #'\r'       // Skip carriage return
    ADDNE   R7, #1          // increase buffer pointer
    ADDNE   R8, #1         // Increase loop counter
    CMP     R8, #20        // Check for the end of the buffer
    BLT     readline_loop
readline_done:
    BL      check_read_error
    MOV     R0,#0           // Put a 0 at the end of the buffer
    STRB    R0,[R7]

    // Check for an empty line
    LDR     R7,=buffer      
    LDRB    R0,[R7]
    CMP     R0,#0
    BEQ     next_section

    // Convert string to integer and add to sum
    LDR     R0,=buffer
    BL      atoi            // Covert string to integer
    ADD     R12,R12,R0      // Add value to sum
    B       readline        // Loop

next_section:
    CMP     R12,#0          // If the sum is 0, this is EOF
    BEQ     done
    CMP     R12,R11         // Compare sum to max1
    MOVGT   R9,R10          // Shift down if sum is larger
    MOVGT   R10,R11         // Shift down if sum is larger
    MOVGT   R11,R12         // Copy sum to max1 if the sum is larger
    BGT     clear_sum       
    CMP     R12, R10        // Compare sum to max2
    MOVGT   R9,R10          // Shift down if sum is larger
    MOVGT   R10,R12         // Copy sum to maxw if the sum is larger
    BGT     clear_sum       
    CMP     R12, R9         // Compare sum to max3
    MOVGT   R9,R12          // Copy sum to maxw if the sum is larger

clear_sum:
    MOV     R12,#0          // Clear sum
    B       readline        // Read next line

no_arguments:
    LDR     R0,=no_args     // Print a help message
    BL      puts
    B       error

done:
    ADD     R12, R11, R10   // Add R11 to R10 and store in R12
    ADD     R12, R12, R9    // Add R9 to R12 and store in R12
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
