#AUTHOR: Hector Guarneros

CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -Werror -g -O0
LDFLAGS ?= -pthread

all: aesdsocket

default: aesdsocket

aesdsocket: aesdsocket.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

clean:
	rm -f aesdsocket *.o
