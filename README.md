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
./bfnasm examples/helloworld.bf

```

## For Developers
- The "infinite" tape is (configurably) 30k one-byte cells long, and does implement wraparound so that programs can be 30k long on either side or 20k long on one and 10k on the other without major issues. There's possibly a better way to implement the infinite tape without wraparound and still have it play nice with the language, namely doubly linked lists. However, that's left for a possible future implementation and has its own cost in performance and memory.
- The interpreter loads the entire program at once and has a (configurable) limit of 100MB (including comments) which should be more than enough for most all bf programs. Another choice would be implementing a chunking system where the program is loaded in chunks and the interpreter only loads the next chunk when it's needed. This would be a good idea for a future implementation, but it's not a priority at the moment. Also, preprocessing might be a good idea to remove comments and compress all 8 possible instructions into 3 bits each, but again, not a priority.
- It might be useful to add some non-cannonical instructions to the language for useful debugging, such as massive memory dumps, stepping through the program and adding breakpoints, but this might be better as a standalone debugger rather than a part of the interpreter itself.
- Additionally, basic error handling (checking that [] match, as this is more or less the only way to make invalid programs in bf) might be a good idea.

## License
[MIT](https://choosealicense.com/licenses/mit/)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.