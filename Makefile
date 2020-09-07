.PHONY: all
all: real

fns.o: fns.asm
	nasm -O0 -f elf64 fns.asm -o fns.o

main.o: main.asm
	nasm -O0 -f elf64 main.asm -o main.o

real: fns.o main.o
	ld fns.o main.o -o real

.PHONY: clean
clean:
	rm -rf *.o
	rm real
