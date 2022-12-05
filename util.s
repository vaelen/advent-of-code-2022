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

// Helper functions

// Exported Methods
    .global itoa
    .global div
    .global word_to_binary
    .global newline
    .global print_registers
    .global print_r0
    .global print_r0_verbose
    .global print_r0_binary
    .global print_memory_binary
    .global strlen
    .global strcmp
    .global fputs
    .global puts
    .global int_string
    .global check_read_error

// Code Section
    
itoa:
    // Converts an integer to a string
    // Arguments: integer in R0, memory address in R1
    // This works by using recursion
    // It builds the value backwards on the stack then pops it off in the right order
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    MOV     R4,R1               // Store the memory address in R4
    BL      itoa_helper         // Recurse
    MOV     R6,#0               // R6 = null terminator
    STREQB  R6,[R4]             // Add a null terminator
    POP     {R0-R12,PC}         // Pop the registers off of the stack and return

itoa_helper:
    // Arguments: integer in R0, memory address in R4
    PUSH    {R5,LR}             // Push the registers on to the stack
    MOV     R1,#10              // We will divide R0 by 10
    BL      div                 // Divide R0 by R1 and return remainder in R0
    MOV     R5,R0               // Put the remainder in R5
    MOV     R0,R2               // Move the quotient into R0 for the next iteration
    CMP     R0,#0               // Is this the end of the string?
    BLNE    itoa_helper         // If not, recurse 
    ADD     R6,R5,#48           // Add 48 to the remainder to get an ASCII character
    STRB    R6,[R4],#1          // Store the byte into memory and increment the memory location
    POP     {R5,PC}             // Pop the registers off of the stack and return

word_to_binary:
    // Converts a word to a binary string
    // Arguments: word in R0, string memory address in R1 (must be 32 bytes long)
    PUSH    {R0-R12,LR}         // Push existing registers on to the stack
    MOV     R2,#1               // R2 = bitmask
    LSL     R2,#31              //   Most significant digit
wtb_loop:
    CMP     R2,#0               // Check to see if we're finished
    BEQ     wtb_done            // If so, return
    TST     R0,R2               // Check if bit is set
    MOVNE   R3,#49              // If 1, place an ASCII 1 in R3
    MOVEQ   R3,#48              // If 0, place an ASCII 0 in R3
    STRB    R3,[R1]             // Store the value of R3 into the string
    ADD     R1,#1               // Move to the next byte of the output string
    LSR     R2,#1               // Shift bitmask to next bit of input
    B       wtb_loop            // Loop
wtb_done:   
    POP     {R0-R12,PC}         // Return    
    
div:
    // Divides R0 by R1
    // Returns the quotient in R2, and the remainder in R0
    PUSH    {R4-R12,LR}         // Push the existing registers on to the stack
    MOV     R4,R1               // Put the divisor in R4
    CMP     R4,R0,LSR #1        // Compare the divisor (R0) with 2xR4
div_loop1:
    MOVLS   R4,R4,LSL #1        // Double R4 if 2xR4 < divisor (R0)
    CMP     R4,R0,LSR #1        // Compare the divisor (R0) with 2xR4
    BLS     div_loop1           // Loop if 2xR4 < divisor (R0)
    MOV     R2,#0               // Initialize the quotient
div_loop2:
    CMP     R0,R4               // Can we subtract R4?
    SUBCS   R0,R0,R4            // If we can, then do so
    ADC     R2,R2,R2            // Double the quotient, add new bit
    MOV     R4,R4,LSR #1        // Divide R4 by 2
    CMP     R4,R1               // Check if we've gone past the original divisor
    BHS     div_loop2           // If not, loop again
    POP     {R4-R12,PC}         // Pop the registers off of the stack and return

    newline:
    // Print a newline character
    PUSH    {R0,LR}
    LDR     R0,=newline_s
    BL      fputs 
    POP     {R0,PC}

print_registers:
    PUSH    {R0-R12,LR}         // Push the existing registers on to the stack
    PUSH    {R1}
    MOV     R1,#0
    BL      print_r0_verbose
    POP     {R0}
    MOV     R1,#1
    BL      print_r0_verbose
    MOV     R0,R2
       MOV     R1,#2
    BL      print_r0_verbose
    MOV     R0,R3
    MOV     R1,#3    
    BL      print_r0_verbose
    MOV     R0,R4
       MOV     R1,#4
    BL      print_r0_verbose
    MOV     R0,R5
    MOV     R1,#5
    BL      print_r0_verbose
    MOV     R0,R6
       MOV     R1,#6
    BL      print_r0_verbose
    MOV     R0,R7
       MOV     R1,#7
    BL      print_r0_verbose
    MOV     R0,R8
       MOV     R1,#8
    BL      print_r0_verbose
    MOV     R0,R9
       MOV     R1,#9
    BL      print_r0_verbose
    MOV     R0,R10
    MOV     R1,#10
    BL      print_r0_verbose
    MOV     R0,R11
    MOV     R1,#11
    BL      print_r0_verbose
    MOV     R0,R12
    MOV     R1,#12
    BL      print_r0_verbose
    POP     {R0-R12,PC}         // Return when loop completes, restore registers

print_r0_verbose:
    // R0 = value
    // R1 = register number
    PUSH    {R0,R1,R2,LR}       // Push the existing registers on to the stack
    PUSH    {R0}
    LDR     R0,=R_s             // Print R
    BL      fputs
    MOV     R0,R1
    LDR     R1,=int_string      // Print register number
    BL      itoa
    MOV     R0,R1
    BL      fputs
    LDR     R0,=colon_s         // Print separator
    BL      fputs
    POP     {R0}                // Print register value
    LDR     R1,=int_string      // | Write to the int_string memory location
    BL      itoa                // | Get string representation
    MOV     R0,R1               // Print the character string
    BL      fputs               // |
    LDR     R0,=space_s         // Print a space
    BL      fputs               // |
    POP     {R0,R1,R2,PC}          // Return when loop completes, restore registers
    
print_r0:
    PUSH    {R0,R1,LR}          // Push the existing registers on to the stack
    LDR     R1,=int_string      // | Write to the int_string memory location
    BL      itoa                // | Get string representation
    MOV     R0,R1               // Print the character string
    BL      fputs               // |
    LDR     R0,=space_s         // Print a space
    BL      fputs               // |
    POP     {R0,R1,PC}          // Return when loop completes, restore registers

print_r0_binary:
    PUSH    {R0,R1,LR}          // Push existing registers on to the stack
    LDR     R1,=binary_string   // Memory location of the string to print
    BL      word_to_binary      // Convert R0 to binary
    MOV     R0,R1               // Print the string
    BL      puts                
    POP     {R0,R1,PC}          // Return

print_memory_binary:
    // Prints a section of memory in binary
    // Arguments: R0 = memory start location, R1 = memory end location
    CMP     R0,R1               // Check for valid input values
    BXGT    LR                  // If R0 is greater than R1, return
    PUSH    {R0-R3,LR}          // Push existing registers on to the stack
    MOV     R2,R0               // R2 = Current memory location
    MOV     R3,R1               // R3 = Last memory location
    LDR     R1,=binary_string   // Memory location of the string to print
pmb_loop:
    LDR     R0,[R2]             // Load word of memory into R0
    BL      word_to_binary      // Convert R0 to binary
    MOV     R0,R1               // Print the string
    BL      puts                
    ADD     R2,#4               // Increment the memory location
    CMP     R2,R3               // Are we done?
    BLE     pmb_loop            // If not, loop
pmb_done:   
    POP     {R0-R3,PC}          // Return
    
puts:
    // Print the null terminated string at R0, followed by a newline
    PUSH    {R0,LR}             // Push the existing registers on to the stack
    BL      fputs               // Print the null terminated string at R0
    BL      newline             // Print a newline character
    POP     {R0,PC}             // Return when loop completes, restore registers
                
fputs:
    // Print the null terminated string at R0
    PUSH    {R0-R3,LR}         // Push the existing registers on to the stack
    BL      strlen              // Get the length of the string
    MOV     R2,R1               // String length is in R1
    MOV     R1,R0               // String starts at R0
    MOV     R0,#1               // Write to STDOUT
    BL      write               // Call write system call
    POP     {R0-R3,PC}         // Pop the registers off of the stack and return
    
strlen:
    // Finds the length of the string at address R0
    // Returns the length in R1 (TODO: This should be R0)
    PUSH    {R2,LR}             // Push the existing registers on to the stack
    SUBS    R1,R0,#1            // R1 = One byte before the first memory location
strlen_loop:
    ADDS    R1,R1,#1            // R1 = Current memory location
    LDRB    R2,[R1]             // R2 = Current byte
    CMP     R2,#0               // Check for null
    BNE     strlen_loop         // Loop if not null
    SUBS    R1,R1,R0            // R1 = Length of string
    POP     {R2,PC}             // Pop the registers off of the stack and return

strcmp:
    // Compares two strings
    PUSH    {R2-R3,LR}
strcmp_loop:
    LDRB    R2,[R0]             // Load next byte of string at R0
    LDRB    R3,[R1]             // Load next byte of string at R1
    CMP     R2,R3               // Compare bytes
    BLT     strcmp_lt
    BGT     strcmp_gt
    CMP     R2, #0              // If they are equal and both 0, return 0
    MOVEQ   R0, #0
    BEQ     strcmp_done
    ADDS    R0,R0,#1            // Check the next byte
    ADDS    R1,R1,#1
    B       strcmp_loop
strcmp_lt:
    MOV     R0, #-1             // If the first string is less, return -1
    B       strcmp_done
strcmp_gt:
    MOV     R0, #1              // If the first string is more, return 1
strcmp_done:
    POP     {R2-R3,PC}

check_read_error:
    PUSH    {R0,R1,LR}
    MOV     R1,R0
    MOV     R0,#0
    CMP     R1,#-4              // Check for interrupted system call
    LDREQ   R0,=eintr
    CMP     R1,#-5              // Check for IO error
    LDREQ   R0,=eio   
    CMP     R1,#-9              // Check for bad file descriptor
    LDREQ   R0,=ebadf
    CMP     R1,#-11             // Check for try again
    LDREQ   R0,=efault
    CMP     R1,#-14             // Check for bad address
    LDREQ   R0,=eagain
    CMP     R1,#-21             // Check for a directory
    LDREQ   R0,=eisdir
    CMP     R1,#-22             // Check for invalid
    LDREQ   R0,=einval
    CMP     R0,#0               // If we have a message to print, then print it
    BLNE    puts         
    POP     {R0,R1,PC}    
    
// Data Section
    
.data

binary_string:  .asciz "00000000000000000000000000000000" // one word (4 bytes)
int_string:     .asciz "0000000000" // max 4294967296
newline_s:      .asciz "\n"
space_s:        .asciz " "
R_s:            .asciz "R"
colon_s:        .asciz ": "

// Error Codes
eintr:  .asciz "[ERROR] Interrupted System Call: The call was interrupted by a signal before any data was read."
eio:    .asciz "[ERROR] I/O Error"
ebadf:  .asciz "[ERROR] Bad File Number: Not a valid file descriptor"
eagain: .asciz "[ERROR] Try Again: Read would block but file is marked non-blocking"
efault: .asciz "[ERROR] Bad Address: Buffer is outside your addressible address space"
eisdir: .asciz "[ERROR] Trying to Read From a Directory Instead of a File"
einval: .asciz "[ERROR] Invalid Argument: Could not read file"