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

// Day 1 - https://adventofcode.com/2022/day/1


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

.global exit
.global _start

_start:
    MOV     R0, #0
    B       exit

