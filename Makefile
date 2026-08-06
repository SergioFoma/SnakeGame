CC=riscv64-linux-gnu-gcc

COMPILE_FLAGS=-c -Wall -Werror -Wextra
LINKER_FLAGS=-static -Wl,--no-relax
DEBUG_FLAGS=

OUT=a.out
ASM_FILES=main.S
OBJECTS=$(ASM_FILES:%.S=%.o)

#ifdef DEBUG
DEBUG_FLAGS=-g
#endif

.PHONY: all clean rebuild

all: $(OUT)

$(OUT): $(OBJECTS)
	$(CC) $(LINKER_FLAGS) $(OBJECTS) -o $(OUT)

%.o: %.S
	$(CC) $(DEBUG_FLAGS) $(COMPILE_FLAGS) $< -o $@

clean:
	-rm *.o
	-rm $(OUT)

rebuild:
	$(MAKE) clean
	$(MAKE) all
