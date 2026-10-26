# 42.ft_turing
The goal of this project is to write a program able to simulate a single headed, single tape Turing machine from a machine description provided in json.

## Machines

### 3 - Zero One Dectection
The rules are:
- Sequence of '0' are always before sequence of '1'
- There must be an equal number of '0' and '1'

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




## Ressources
- [Core lib documentation](https://ocaml.org/p/core/v0.17.2/doc/core/Core/index.html)
