# The @ symbol removes the out put of the compilation prosess and makes
# the output alot cleaner
all:
	nasm -f elf64 -o httpserver.o src/httpserver.asm
	ld httpserver.o -o httpserver.out

debug:
	nasm -g -f elf64 -o httpserver.o src/httpserver.asm
	ld httpserver.o -o httpserver.out

