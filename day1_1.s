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

// Day 1, Part 1 - https://adventofcode.com/2022/day/1


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
    This list represents the Calories of the food carried by five Elves:

    The first Elf is carrying food with 1000, 2000, and 3000 Calories, a total of 6000 Calories.
    The second Elf is carrying one food item with 4000 Calories.
    The third Elf is carrying food with 5000 and 6000 Calories, a total of 11000 Calories.
    The fourth Elf is carrying food with 7000, 8000, and 9000 Calories, a total of 24000 Calories.
    The fifth Elf is carrying one food item with 10000 Calories.
    In case the Elves get hungry and need extra snacks, they need to know which Elf to ask: they'd like to know how many Calories are being carried by the Elf carrying the most Calories. In the example above, this is 24000 (carried by the fourth Elf).

    Find the Elf carrying the most Calories. How many total Calories is that Elf carrying?
*/

// Solution
/*
    Since we only care about the elf with the highest number of calories, we don't need to keep all the data in memory.
    In fact, we only need the largest total, not even the identifier of which elf that is, so we only need one
    variable to store our final answer. 
    
    The process is fairly simple:
        1. Initalize two variables, sum and max, to 0. 
        2. Open the input file
        3. For each line of input
        4.  If the line is not blank, convert it to an integer and add it to sum
        5.  If the line is blank:
        6.   If sum is greater than max, set max to sum
        7.   Set sum to 0
        8. Print sum
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
    MOV     R11, #0 // max

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
    CMP     R10, #20        // Check for the end of the buffer
    BLT     readline_loop
readline_done:
    BL      check_read_error
    MOV     R0,#0           // Put a 0 at the end of the buffer
    STRB    R0,[R9]

    // Check for an empty line
    LDR     R9,=buffer      
    LDRB    R0,[R9]
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
    CMP     R12,R11         // Compare sum to max
    MOVGT   R11,R12         // Copy sum to max if the sum is larger
    MOV     R12,#0          // Clear sum
    B       readline        // Read next line

no_arguments:
    LDR     R0,=no_args     // Print a help message
    BL      puts
    B       error

done:
    MOV     R0,R11          // Copy max to R0
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
