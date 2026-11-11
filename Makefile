# Native port on Linux/macOS (needs SDL2 development files and a C compiler): make; ./excitebike excitebike.nes
CC ?= cc
CFLAGS ?= -O2
SRC = port/main.c port/ppu.c port/apu.c port/audiomod.c c/excitebike.c
excitebike: $(SRC) $(wildcard c/*.inc c/*.h port/*.h port/*.inc)
	$(CC) -std=gnu11 $(CFLAGS) -Wno-unused-label -Wno-unused-function -o $@ $(SRC) $$(sdl2-config --cflags --libs) -lm
