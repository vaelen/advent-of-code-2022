#ARCH=none-eabi
ARCH=linux-gnueabi
#ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
ASFLAGS=-g
LDFLAGS=

UTIL=syscalls.o util.o
DAY1=day1.o

all: day1

day1: $(DAY1)
	$(LD) $(LDFLAGS) $(UTIL) $(DAY1) -o bin/$@

util: $(UTIL)

.o:
	$(AS) $(ASFLAGS) $<.s -o $(OBJ_DIR)/$@

clean:
	rm -f *.o