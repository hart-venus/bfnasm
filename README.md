# BFNasm
A simple [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) interpreter written in NASM.
For execution using a linux x86_64 environment.

## Usage

```bash
# compile using nasm 
nasm -f elf64 bfnasm.nasm -o bfnasm.o
# link object file using ld
ld bfnasm.o -o bfnasm
# run the executable with command line arguments.
./bfnasm helloworld.bf

```