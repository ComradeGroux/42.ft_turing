# 42.ft_turing
The goal of this project is to write a program able to simulate a single headed, single tape Turing machine from a machine description provided in json.

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

## Ressources
- [Core lib documentation](https://ocaml.org/p/core/v0.17.2/doc/core/Core/index.html)
