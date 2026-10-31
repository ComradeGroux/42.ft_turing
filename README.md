# 42.ft_turing
The goal of this project is to write a program able to simulate a single headed, single tape Turing machine from a machine description provided in json.

## Run
Build with `make`
```
usage: ft_turing [-h] jsonfile input
       ft_turing [-h] jsonfile -c inputs_file

positional arguments:
    jsonfile                        json description of the machine
    input                           input of the machine

optional arguments:
    -h, --help                      show this help message and exit
    -c, --complexity inputs_file    estimate the time complexity of the
                                    machine from the inputs in inputs_file
                                    (one input per line, at least 3 of different lengths)
```

Examples:
```
./ft_turing -h
./ft_turing machines/extra_write_hello.json "h"
./ft_turing machines/extra_find_1.json "0001011"
./ft_turing machines/sequence_02n.json "0000"
./ft_turing machines/sequence_0n1n.json "0011"
./ft_turing machines/unary_sub.json "111-11="
./ft_turing machines/is_palindrome.json "0110"
./ft_turing machines/unary_addition.json "111+11="
./ft_turing machines/sequence_0n1n_slow.json "0011"
./ft_turing machines/unary_sub.json -c input/unary_sub.txt
```

## Machines
### 1 - Unary addition
The rules are:
- Sequence of addition
- The sequence must be terminated by '='

Example:
- Pass: 11+1=, 11+1+1=
- Fail: 1, 11=, 1+1+=

The machine:
- Logic: Find '=' and replace it by the blank character -> Replace the character just before by '=' -> Find the last '+' and Replace it by '1' -> Find the new last '+' -> Repeat
- States:
    - **scanright**: Goes until it found '=' and then move to *addone*.
    - **addone**: Replace '1' by '=' and then move to *replaceone*.
    - **replaceone**: Goes to the last '+' (from Right to Left) and then move to *end*.
    - **end**: Check if there still is something to do (Found '+' -> move to *scanright*). Otherwise *HALT* the machine.
    - **HALT**: End state.


### 2 - Is Palindrome
The rule are:
- Sequence of '0' and '1'

Example:
- Pass: 1, 101, 010010
- Fail: 01, 1101, 0100101

The machine:
- Logic: Check first character and cross it with '-' -> Go to the end of the tape and if it is the same character write 'y' or 'n' otherwise -> Goes back to the first character that is not blank or '-' -> Repeat
- States:
    - **init**: Validate the first character and move to the right state (*get_last_zero* or *get_last_one*).
    - **get_last_zero**: Goes to the end of the tape and then call *is_zero*.
    - **is_zero**: Verify that the character is '0'. *deny* it if necessary, move to *get_first_char* otherwise.
    - **get_last_one**: Goes to the end of the tape and then call *is_one*.
    - **is_one**: Verify that the character is '1'. *deny* it if necessary, move to *get_first_char* otherwise.
    - **get_first_char**: Return to the tape's beginning and then move to *init*
    - **deny**: Goes to the end of the tape, write 'n' and then *HALT*. Used if *is_zero* or *is_one* failed
    - **HALT**: End state


### 3 - Sequence_0n1n
The rules are:
- Sequence of '0' are always before sequence of '1'
- There must be an equal number of '0' and '1' to satisfy $0^n1^n$

Example:
- Pass: 01, 0011, 000111
- Fail: 011, 001, 10, 0101

There are two versions of this machine:
- `machines/sequence_0n1n.json`: fast version, $O(n \log n)$
- `machines/sequence_0n1n_slow.json`: slow version, $O(n^2)$

#### Fast version - $O(n \log n)$
The machine:
- Logic: Each pass goes from left to right and crosses every other remaining '0' and every other remaining '1' with 'x' (the 1st, 3rd, 5th...), while keeping track of the parity of the remaining '0' and '1'. If the parities are different at the end of the pass then the counts can't be equal -> 'n'. Otherwise rewind and do another pass. Each pass halves the number of remaining '0' and '1', so there are $\log n$ passes of $n$ steps each. If everything is crossed -> 'y'.
- States:
    - **START**: Validate the first character being '0'.
    - **PARSE**: Parse the tape to allow only '0' and '1'.
    - **REWIND**: Go back to the start of the tape (after PARSE or after a pass).
    - **PASS**: Start a pass. Skip 'x'. Cross the first '0' found. If a '1' is found first then there are more '1' than '0'. If the end is reached then everything is crossed and the input is valid.
    - **0_EVEN**/**0_ODD**: Go through the '0', keep track of the parity and cross every other one. If a '1' is found, cross it and move to the '1' states. If the end is reached then there is no '1' left.
    - **1_EVEN_0_EVEN**/**1_ODD_0_EVEN**/**1_EVEN_0_ODD**/**1_ODD_0_ODD**: Same thing for the '1', while remembering the parity of the '0'. A '0' after a '1' is invalid. At the end of the tape, *REWIND* if the parities match, 'n' otherwise.
    - **NO**: Result state. Pass through all characters to the end of the input.
    - **END**: End state. Prints 'y' or 'n' depending on the previous state.

#### Slow version - $O(n^2)$
The machine:
- Logic: Find '0' -> Cross '0' with 'a' -> Find next '1' -> cross '1' with 'b' -> Find next '0' -> Cross '0' with 'a' -> Repeat till run out of '0' or '1'
- States:
    - **START**: Validate the first character being '0'.
    - **PARSE**: Parse the tape to allow only '0' and '1'.
    - **REWIND**: Go back to the start after PARSE and start the logic.
    - **ZERO**: Find the next '0'. If we find '0', cross it with 'a'. If we find 'b' then we run out of '0'.
    - **ONE**: Find the next '1'. Cross '1' with 'b' if found. Pass through 'b' and '0'. If found '.' then we run out of '1'.
    - **AB**: Find 'a' and 'b'. They act as delimiter so we know where we have stopped before
    - **YES**/**NO**: Result states. Pass though all characters no matter where we are to the end of the input.
    - **END**: End state. Prints 'y' or 'n' depend on Result states.

### 4 - Sequence_02n
The rules are:
- Only sequence of '0'
- The number of '0' must be $0^{2n}$. In another word, any even number of '0' is valid.

Example:
- Pass: 00 ($0^{2*1}$), 0000 ($0^{2*2}$), 000000 ($0^{2*3}$)
- Fail: 0, 000, 00000

The machine:
- Logic: Start in state EVEN, which mean position EVEN (pos = 0) -> move right into ODD (pos = 1) -> move right into EVEN (pos = 2) -> ... -> until the end, if end reached and state is EVEN then 'y' and END
- States:
    - **EVEN**: Position is even.
    - **ODD**: Position is odd.
    - **NO**: Input is invalid, move all the way to the end and 'n'.
    - **END**: End state just to stop the machine.

## Extra
Additional machines, made to show other time complexities with `-c`.

### Write_hello
The rules are:
- Sequence of 'h', 'e', 'l' and 'o'

Example:
- "h" -> "hello."
- "hellohello" -> "hello.ello"

The machine:
- Logic: Ignore the input and overwrite the first 6 cells with "hello." The machine always does exactly 6 steps, whatever the input length -> $O(1)$
- States:
    - **FIRST**: Step 1. Write 'h' and move to *SECOND*.
    - **SECOND**: Step 2. Write 'e' and move to *THIRD*.
    - **THIRD**: Step 3. Write 'l' and move to *FOURTH*.
    - **FOURTH**: Step 4. Write 'l' and move to *FIFTH*.
    - **FIFTH**: Step 5. Write 'o' and move to *SIXTH*.
    - **SIXTH**: Step 6. Write '.' and move to *END*.
    - **END**: End state.

### Find_1
The rules are:
- Sequence of '0' and '1'

Example:
- "0001011" -> "000.011"
- "000" -> "000"

The machine:
- Logic: Read '0' until the first '1' -> Replace it by '.' and stop. Only the cells up to the first '1' are read, the rest of the tape is never visited.
- States:
    - **SCAN**: Pass through '0'. On '1', write '.' and move to *END*. If the end of the input is reached, move to *END*.
    - **END**: End state.

## Bonus
### Usage
Run a machine with `-c` (or `--complexity`) and a file of inputs, one per line. Inputs must cover at least 3 different lengths. Inputs that time out (10 s) or get blocked are dropped from the estimation.

Example command for each machine:
```
./ft_turing machines/extra_write_hello.json -c input/extra_write_hello.txt
./ft_turing machines/extra_find_1.json -c input/extra_find_1.txt
./ft_turing machines/sequence_02n.json -c input/sequence_02n.txt
./ft_turing machines/sequence_0n1n.json -c input/sequence_0n1n.txt
./ft_turing machines/unary_sub.json -c input/unary_sub.txt
./ft_turing machines/is_palindrome.json -c input/is_palindrome.txt
./ft_turing machines/unary_addition.json -c input/unary_addition.txt
./ft_turing machines/sequence_0n1n_slow.json -c input/sequence_0n1n.txt
```

### Step definition
A step is composed of:
1. Reading the input symbol under R/W head on the tape.
2. Calculating the next state of Turing machine, output symbol to write and movement of R/W head either left or right.
3. Write the symbol on the tape.
4. Shift the R/W head.

### Linear regression
To find the best matching time complexity, we will run the machine on a big number of valid inputs of various input length. Then for each time complexity type, we will compute the predicted number of steps based on the input and compare to the real number of steps. We will then attempt to construct a straight line that minimize the error between the predicted value and the real value. This is a **simple linear regression with 1 independent variable**. The best fitted line will be our pick for time complexity.

For a data set of single feature, we will use the closed form of linear regression called **Normal Equation**. This will produce thetas for our linear function.

Using the thetas produced by linear regression. We will construct the list of predicted steps, then compare to the real steps produced by our machine to compute average error in steps.

The complexity with the smallest error is picked.

### Results
Results for inputs in /input

| Machine | Estimated | Error |
|---|---|---|
| extra_write_hello | O(1) | 0 |
| extra_find_1 | O(log n) | 0 |
| sequence_02n | O(n) | 0 |
| sequence_0n1n | O(n log n) | 489 |
| unary_sub | O(n²) | 147 |
| is_palindrome | O(n²) | 265 |
| unary_addition | O(n²) | 441 |
| sequence_0n1n_slow | O(n²) | 530 |

## Ressources
- [Core lib documentation](https://ocaml.org/p/core/v0.17.2/doc/core/Core/index.html)
- [Time complexity for Turing Machine](https://abcdofalgorithms.wordpress.com/2014/11/26/how-to-compute-time-complexity-in-turing-machine/)
- [Analysis of algorithms](https://www.geeksforgeeks.org/dsa/analysis-of-algorithms/)
- [Linear regression](https://en.wikipedia.org/wiki/Simple_linear_regression#Formulation_and_computation)
- [Least square error](https://en.wikipedia.org/wiki/Ordinary_least_squares#Estimation)
