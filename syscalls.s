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

// This file include Linux system calls
// Reference: https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl
// Reference: https: //github.com/torvalds/linux/blob/master/include/linux/syscalls.h
    
// Exported Methods
    .global exit
    .global fork
    .global read
    .global write
    .global open
    .global close
    .global getpid
    .global getrandom
    .global open_read
    .global open_write

// Code Section

exit:
    // Exit program
    // Arguments: R0 = Return code
    MOV     R7,#1               // Syscall numbe, 1 = exit
    SWI     0                   // Perform system call

fork:
    // Fork new process
    // Arguments: R0 = Pointer to a pt_regs struct
    PUSH    {R7,LR}             // Push the existing registers on to the stack
    MOV     R7,#2               // Syscall numbe, 2 = fork
    SWI     0                   // Perform system call
    POP     {R7,PC}             // Pop the registers off of the stack and return
    
read:
    // Read bytes from the given file handle
    // Arguments: R0 = File handle, R1 = Buffer, R2 = Bytes to Read
    PUSH    {R7,LR}             // Push the existing registers on to the stack
    MOV     R7,#3               // Syscall number: 3 is read()
    SWI     0                   // Read from file handle
    POP     {R7,PC}             // Pop the registers off of the stack and return

write:
    // Write bytes to the given file handle
    // Arguments: R0 = File handle, R1 = Buffer, R2 = Bytes to Write
    PUSH    {R7,LR}             // Push the existing registers on to the stack
    MOV     R7,#4               // Syscall number: 4 is write()
    SWI     0                   // Write to file handle
    POP     {R7,PC}             // Pop the registers off of the stack and return

open:
    // Opens a file
    // Arguments: 
    //   R0 = Memory address of null terminated path string.
    //   R1 = Flags
    //   R2 = Mode
    // Returns file handle in R3
    PUSH    {R7,LR}             // Push the existing registers on to the stack
    MOV     R7,#5               // Syscall number: 5 is open()
    SWI     0                   // Open file handle
    POP     {R7,PC}             // Pop the registers off of the stack and return

close:
    // Closes a file
    // Arguments: R0 = File handle
    PUSH    {R7,LR}             // Push the existing registers on to the stack
    MOV     R7,#6               // Syscall number: 6 is close()
    SWI     0                   // Close file handle
    POP     {R7,PC}             // Pop the registers off of the stack and return

getpid:
    // Returns the current process id
    PUSH    {R7,LR}             // Push the existing registers on to the stack
    MOV     R7,#20              // Syscall number: 20 is getpid()
    SWI     0                   // Close file handle
    POP     {R7,PC}             // Pop the registers off of the stack and return

getrandom:
    // Gets random bytes from /dev/urandom
    // Arguments: R0 = Memory location of buffer
    //            R1 = Number of bytes to read
    //            R2 = Flags (GRND_RANDOM and/or GRND_NONBLOCK)
    //                  GRND_NONBLOCK (1) - Return -1 if entropy pool is not yet initialized
    //                  GRND_RANDOM (2) - Use /dev/random instead of /dev/urandom
    PUSH    {R7,LR}             // Push the existing registers on to the stack
    MOV     R7,#384             // Syscall number: 384 is getrandom()
    SWI     0                   // Close file handle
    POP     {R7,PC}             // Pop the registers off of the stack and return

open_read:
    // Opens a file for reading
    // Arguments: R0 = Memory address of null termianted path string
    // Returns file handle in R3
    PUSH    {R1,R2,LR}          // Push the existing registers on to the stack
    MOV     R1,#0               // Read Only Flag
    MOV     R2,#0               // Mode (Ignored)
    BL      open                // Open the file
    POP     {R1,R2,PC}          // Pop the registers off of the stack and return

open_write:
    // Opens a file for writing
    // Arguments: R0 = Memory address of null termianted path string
    // Returns file handle in R3
    PUSH    {R1,R2,LR}          // Push the existing registers on to the stack
    MOV     R1,#1               // Write Only Flag
    MOV     R2,#0               // Mode (Use Default)
    BL      open                // Open the file
    POP     {R1,R2,PC}          // Pop the registers off of the stack and return

    