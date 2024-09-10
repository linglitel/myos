ASM=nasm
CC=gcc
LD=ld

ASMFLAGS=-f elf64
CFLAGS=-ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -nostdlib -fno-builtin -fno-stack-protector -Wall -Wextra -Werror -c
LDFLAGS= -n -nostdlib

SRCDIR=.
OBJDIR=obj
BINDIR=bin

SOURCES_ASM := $(wildcard $(SRCDIR)/boot/*.s)
SOURCES_C := $(wildcard $(SRCDIR)/kernel/*.c) $(wildcard $(SRCDIR)/lib/*.c)
OBJECTS_ASM := $(patsubst $(SRCDIR)/%.s,$(OBJDIR)/%.o,$(SOURCES_ASM))
OBJECTS_C := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SOURCES_C))

KERNEL=$(BINDIR)/kernel.bin

.PHONY: all clean

all: $(KERNEL)

$(KERNEL): $(OBJECTS_ASM) $(OBJECTS_C)
	@mkdir -p $(@D)
	$(LD) $(LDFLAGS) -T linker.ld -o $(KERNEL) $(OBJECTS_ASM) $(OBJECTS_C)

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	@mkdir -p $(@D)
	$(ASM) $(ASMFLAGS) $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(SRCDIR)/include -c $< -o $@

clean:
	rm -rf $(OBJDIR) $(BINDIR)
